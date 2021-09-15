# frozen_string_literal: true

require "shrine"
require "azure/storage/blob"
require "content_disposition"

require "uri"
require "cgi"
require "tempfile"

class Shrine
  module Storage
    class AzureBlob
      attr_reader :client, :container_name, :scheme, :public

      def initialize(container_name, client, public: , scheme: )
        account_name = client.client.options()[:storage_account_name]
        access_key = client.client.options()[:storage_access_key]

        @container_name = container_name
        @sas = Azure::Storage::Common::Core::Auth::SharedAccessSignature.new account_name, access_key
        @client = client
        @public = public || false
        @scheme = scheme || "https"
      end

      class << self
        # Create 
        # @param container_name     [String]  Name of the container storing the blobs
        # @param create_container   [Bool]    Create the container if not exists
        #
        # ==== Attributes
        #
        # * +proxy_uri+    - String. emulator url if emulator is hosted other than localhost.
        #
        # @return [Shrine::Storage::AzureBlob]
        def create_development(container_name:, create_container:false, proxy_uri:nil)
          client = Azure::Storage::Blob::BlobService.create_development(proxy_uri)
          if create_container
            begin
              container = client.create_container(container_name)
            rescue Azure::Core::Http::HTTPError
              container = client.get_container_properties(container_name)
            end
          end

          scheme = "http"
          if proxy_uri
            uri = URI(proxy_uri)
            scheme = uri.scheme
          end
          AzureBlob.new(container_name, client, public:false, scheme:scheme)
        end

        # Create storage using the storage account name and access key
        # @param container_name     [String]  Name of the container storing the blobs
        # @param account_name       [String]  
        # @param access_key         [String]  
        #
        # ==== Attributes
        #
        # * +proxy_uri+    - String. Used with +:use_development_storage+ if emulator is hosted other than localhost.
        #
        # @return [Shrine::Storage::AzureBlob]
        def create(container_name:, account_name:, access_key:, public: nil, scheme: nil)
          client = Azure::Storage::Blob::BlobService.create(
            storage_account_name: account_name,
            storage_access_key: access_key,
          )
          AzureBlob.new(container_name, client, public:public, scheme:scheme)
        end

        # Generic purpose storage creation, allowing to provide all azure storage options
        # @param container_name     [String]  Name of the container storing the blobs
        # @param azure_options      [Hash]    azure/storage/blob Options. see
        #
        #
        # @return [Shrine::Storage::AzureBlob]
        def create_from_options(container_name, azure_options = {}, public: nil, scheme: nil)
          client = Azure::Storage::Blob::BlobService.create(azure_options)
          AzureBlob.new(container_name, client, public:public, scheme:scheme)
        end
      end

      def upload(io, id, shrine_metadata: {}, **_upload_options)
        content_type, filename = shrine_metadata.values_at("mime_type", "filename")
        options = {}
        options[:content_type] = content_type if content_type
        options[:content_disposition] = ContentDisposition.inline(filename) if filename

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
        raise Shrine::FileNotFound, "file #{id} not found on storage #{e.message}"
      end

      def put(io, id, **_options)
        if (path = extract_path(io))
          ::File.open(path, "rb") do |file|
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

      def url(id, public: self.public, scheme: self.scheme, **options)
        uri = @client.generate_uri("#{container_name}/#{id}")

        uri.scheme = scheme.to_s
        unless public
          uri.query = @sas.generate_service_sas_token(
            uri.path,
            service: "b", # blob
            protocol: uri.scheme,
            permissions: "rw", # read
          )
        end
        uri.to_s
      end

      class Tempfile < ::Tempfile
        attr_accessor :content_type
      end
    end
  end
end
