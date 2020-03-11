# frozen_string_literal: true

require_relative 'lib/str_metrics/version'

Gem::Specification.new do |spec|
  spec.name          = 'str_metrics'
  spec.version       = StrMetrics::VERSION
  spec.authors       = ['Anirban Mukhopadhyay']
  spec.email         = ['anirban.mukhop@gmail.com']

  spec.summary       = 'Ruby gem providing native implementations of various string metrics'
  spec.description   = 'Ruby gem (native extension in Rust) providing implementations of various string metrics:'\
  'Sørensen–Dice, Levenshtein, Damerau–Levenshtein, Jaro & Jaro–Winkler. Supports strings convertible to UTF-8.'\
  'All comparisons are done at the grapheme cluster level.'
  spec.homepage      = 'https://github.com/anirbanmu/str_metrics'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['bug_tracker_uri'] = 'https://github.com/anirbanmu/str_metrics/issues'
  spec.metadata['source_code_uri'] = 'https://github.com/anirbanmu/str_metrics'
  spec.metadata['changelog_uri'] = "https://github.com/anirbanmu/str_metrics/blob/v#{spec.version}/CHANGELOG.md"

  spec.files = Dir['lib/**/*.rb', 'src/**/*.rs', 'Cargo.toml', 'extconf.rb', 'LICENSE', 'README.md']

  spec.extensions = %w[extconf.rb]

  spec.add_runtime_dependency     'ffi'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-performance'
  spec.add_development_dependency 'rubocop-rspec'
end
