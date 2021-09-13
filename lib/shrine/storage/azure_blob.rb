# frozen_string_literal: true

require 'shrine'
require 'azure/storage/blob'
require 'content_disposition'

require 'uri'
require 'cgi'
require 'tempfile'

class Shrine
  module Storage
    class AzureBlob

      attr_reader :client, :container_name, :scheme

      def initialize(account_name: nil, access_key: nil, container_name: nil, scheme: nil)
        @container_name = container_name
        @sas = Azure::Storage::Common::Core::Auth::SharedAccessSignature.new account_name, access_key
        @client = Azure::Storage::Blob::BlobService.create(
          storage_account_name: account_name,
          storage_access_key: access_key
        )
        @scheme = scheme || 'https'
      end

      def upload(io, id, shrine_metadata: {}, **_upload_options)
        content_type, filename = shrine_metadata.values_at('mime_type', 'filename')
        options = {}
        options[:content_type] = content_type if content_type
        options[:content_disposition] = ContentDisposition.inline(filename) if filename
        options[:metadata] = shrine_metadata

        put(io, id, **options)
      end

      def extract_path(io)
        if io.respond_to?(:path)
          io.path
        elsif io.is_a?(UploadedFile) &&
              defined?(Storage::FileSystem) &&
              io.storage.is_a?(Storage::FileSystem)
          io.storage.path(io.id).to_s
        end
      end

      def exists?(id)
        @client.get_blob_metadata(container_name, id)
        return true
      rescue Azure::Core::Http::HTTPError
          return false
      end

      def open(id, _rewindable: false, **_options)
        _blob, content = @client.get_blob(container_name, id)
        StringIO.new(content)
      rescue Azure::Core::Http::HTTPError => e
        raise Shrine::FileNotFound, "file #{id} not found on storage #{ e.message }"
      end

      def put(io, id, **_options)
        if (path = extract_path(io))
          ::File.open(path, 'rb') do |file|
            @client.create_block_blob(container_name, id, file.read, timeout: 30, **_options)
          end
        else
          @client.create_block_blob(container_name, id, io.read, **_options)
        end
      end

      def delete(id)
        @client.delete_blob(container_name, id)
      rescue Azure::Core::Http::HTTPError
      end

      def url(id, scheme: self.scheme, **options)
        uri = @client.generate_uri("#{container_name}/#{id}")
        uri.scheme = scheme.to_s
        uri.to_s
      end

      class Tempfile < ::Tempfile
        attr_accessor :content_type
      end
    end
  end
end
