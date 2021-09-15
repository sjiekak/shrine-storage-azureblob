# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shrine/storage/version'

Gem::Specification.new do |spec|
  spec.name          = 'shrine-storage-azureblob'
  spec.version       = Shrine::Storage::VERSION
  spec.authors       = ['Steve Jiekak', 'Ralf Vitasek', 'TQsoft GmbH', 'Dmitriy Bielorusov', 'Syndicode LLC']
  spec.email         = ['devaureshy@gmail.com', 'info@tqsoft.de', 'd.belorusov@gmail.com', 'info@syndicode.com']

  spec.summary       = 'Extend existing shrine gem with using official azure-storage-blob SDK'
  spec.description   = 'Extend existing shrine gem with using official azure-storage-blob SDK'
  spec.homepage      = 'https://github.com/sjiekak/shrine-storage-azureblob'
  spec.license       = 'MIT'

  if spec.respond_to?(:metadata)
    # spec.metadata['allowed_push_host'] = ''

    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/sjiekak/shrine-storage-azureblob'
    spec.metadata['changelog_uri'] = 'https://github.com/sjiekak/shrine-storage-azureblob'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  # spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
  #   `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  # end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }

  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0.2'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rubocop'

  spec.add_dependency "shrine"
  spec.add_dependency 'nokogiri', '>= 1.10.9'
  spec.add_dependency 'azure-storage-blob', '~> 2.0.0'
end
