# Shrine::Storage::AzureBlob
_Provided memory leakless interface for AzureBlob images/files processing within SHRINE_

![Mem leak](https://user-images.githubusercontent.com/1485240/66502907-dc32f380-eace-11e9-89f5-872b0d44b0ee.png)

## Installation

Add this lines to your application's Gemfile:
```ruby
...
gem 'shrine', '~> 2.11'
gem 'azure-storage-blob'
gem 'shrine-redis'
gem 'image_processing', '~> 1.7.1'
gem 'shrine-storage'
gem 'sidekiq'
...
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install shrine-storage-azureblob

## Usage

- **Create file _config/initializers/shrine.rb_**
```ruby
require 'shrine'
require "shrine/storage/azure_blob"

azure_options = {
  account_name: ENV.fetch('AZURE_ACCOUNT_NAME'),
  access_key: ENV.fetch('AZURE_ACCESS_KEY'),
  container_name: ENV.fetch('AZURE_CONTAINER')
}

Shrine.storages = {
  cache: Shrine::Storage::FileSystem.new("tmp", prefix: "uploads/cache"),
  store: Shrine::Storage::AzureBlob.new(**azure_options)
}
```
- **Additional info:**
[Shrine Docs](https://github.com/shrinerb/shrine/blob/master/README.md)
[AzureStorageBlob Docs](https://github.com/Azure/azure-storage-ruby/blob/master/blob/README.md)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/TQsoft-GmbH/shrine-storage-azureblob. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Shrine::Storage project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/TQsoft-GmbH/shrine-storage-azureblob/blob/master/CODE_OF_CONDUCT.md).
