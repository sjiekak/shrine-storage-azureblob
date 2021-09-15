require "rspec/autorun"
require "shrine/storage/linter"
require "./lib/shrine/storage/azure_blob"

describe Shrine::Storage::AzureBlob do
  subject {
    Shrine::Storage::AzureBlob::create_development("test-container", create_container = true)
  }

  describe "#satisfy_shrine_storage_linter" do
    it "satisfy the shrine storage linter" do
      linter = Shrine::Storage::Linter.new(subject)
      linter.call
    end
  end
end
