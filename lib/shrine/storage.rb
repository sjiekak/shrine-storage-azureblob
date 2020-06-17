# frozen_string_literal: true

require 'shrine/storage/version'
require 'shrine/storage/azure_blob'

class Shrine
  module Storage
    class Error < StandardError; end
  end
end
