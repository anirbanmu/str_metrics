# frozen_string_literal: true

require_relative 'lib/str_metrics/version'

Gem::Specification.new do |spec|
  spec.name          = 'str_metrics'
  spec.version       = StrMetrics::VERSION
  spec.authors       = ['Anirban Mukhopadhyay']
  spec.email         = ['anirban.mukhop@gmail.com']

  spec.summary       = 'Ruby gem providing native implementations of various string metrics'
  spec.description   = 'Ruby gem (native extension in Rust) providing implementations of various string metrics'
  spec.homepage      = 'https://github.com/anirbanmu/str_metrics'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/anirbanmu/str_metrics'
  spec.metadata['changelog_uri'] = 'https://github.com/anirbanmu/str_metrics/blob/master/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.extensions = %w[extconf.rb]

  spec.add_runtime_dependency     'helix_runtime', '~> 0.7'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-performance'
  spec.add_development_dependency 'rubocop-rspec'
end
