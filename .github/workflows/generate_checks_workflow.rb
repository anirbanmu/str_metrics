# frozen_string_literal: true

require 'set'
require 'yaml'

require_relative '../../lib/str_metrics/version'

def deep_stringify_keys(element)
  return element.map(&method(:deep_stringify_keys)) if element.is_a?(Array)
  return element.map { |k, v| [k.to_s, deep_stringify_keys(v)] }.to_h if element.is_a?(Hash)

  element
end

DEFAULT_RUBY_VERSION = '3.0'
DEFAULT_RUST_VERSION = '1.51.0'

RUBY_VERSIONS = Set.new([DEFAULT_RUBY_VERSION, '3.0', '2.7', '2.6', '2.5', '2.4', '2.3', 'jruby', 'truffleruby']).to_a.freeze
RUST_VERSIONS = Set.new([DEFAULT_RUST_VERSION, 'stable', 'nightly', '1.51.0', '1.50.0', '1.49.0', '1.48.0', '1.47.0', '1.46.0', '1.45.2', '1.44.1', '1.43.1', '1.42.0', '1.41.1', '1.40.0', '1.39.0', '1.38.0']).to_a.freeze

INSTALL_GEMS_STEPS = [
  {
    name: 'Install gems',
    run: [
      'bundle config path vendor/bundle',
      'bundle install --jobs=4 --retry=3'
    ].join("\n")
  }
].freeze

CACHE_GEMS_STEPS = [
  {
    name: 'Generate Gemfile.lock',
    run: 'bundle lock'
  },
  {
    name: 'Cache gems',
    uses: 'actions/cache@v1',
    with: {
      path: 'vendor/bundle',
      key: "v1-${{ runner.os }}-${{ matrix.ruby }}-gems-${{ hashFiles('**/Gemfile.lock') }}",
      'restore-keys': 'v1-${{ runner.os }}-${{ matrix.ruby }}-gems-'
    }
  }
].freeze

INSTALL_RUST_STEPS = [
  {
    uses: 'actions-rs/toolchain@v1',
    id: 'rust_install',
    with: {
      profile: 'minimal',
      toolchain: '${{ matrix.rust }}',
      default: true
    }
  }
].freeze

CACHE_CARGO_STEPS = [
  {
    name: 'Generate Cargo.lock',
    run: 'cargo generate-lockfile'
  },
  # seems to be failing to restore for the moment: https://github.com/actions/cache/issues/133
  # {
  #   name: 'Cache cargo registry',
  #   uses: 'actions/cache@v1',
  #   with: {
  #     path: '~/.cargo/registry',
  #     key: "v0-${{ runner.os }}-${{ matrix.rust }}-${{ steps.rust_install.outputs.rustc_hash }}-cargo-registry-${{ hashFiles('**/Cargo.lock') }}"
  #   }
  # },
  {
    name: 'Cache cargo index',
    uses: 'actions/cache@v1',
    with: {
      path: '~/.cargo/git',
      key: "v0-${{ runner.os }}-${{ matrix.rust }}-${{ steps.rust_install.outputs.rustc_hash }}-cargo-index-${{ hashFiles('**/Cargo.lock') }}"
    }
  },
  {
    name: 'Cache cargo build',
    uses: 'actions/cache@v1',
    with: {
      path: 'target',
      key: "v0-${{ runner.os }}-${{ matrix.rust }}-${{ steps.rust_install.outputs.rustc_hash }}-cargo-build-target-${{ hashFiles('**/Cargo.lock') }}"
    }
  }
].freeze

INSTALL_RUBY_STEPS = [
  {
    uses: 'ruby/setup-ruby@v1',
    with: { 'ruby-version': '${{ matrix.ruby }}' }
  }
].freeze

TEST_STEPS = [
  { uses: 'actions/checkout@v2' },
  *INSTALL_RUBY_STEPS,
  *INSTALL_RUST_STEPS,
  *CACHE_GEMS_STEPS,
  *CACHE_CARGO_STEPS,
  *INSTALL_GEMS_STEPS,
  {
    name: 'rspec',
    run: 'bundle exec rake spec'
  }
].freeze

RUBOCOP_JOB = {
  rubocop: {
    strategy: {
      matrix: {
        ruby: [DEFAULT_RUBY_VERSION]
      }
    },
    'runs-on': 'ubuntu-latest',
    steps: [
      { uses: 'actions/checkout@v2' },
      *INSTALL_RUBY_STEPS,
      *CACHE_GEMS_STEPS,
      *INSTALL_GEMS_STEPS,
      {
        name: 'rubocop',
        run: 'bundle exec rubocop --parallel'
      }
    ]
  }
}.freeze

def gem_install_job(runs_on)
  {
    "gem-install-#{runs_on}": {
      strategy: {
        matrix: {
          ruby: [DEFAULT_RUBY_VERSION],
          rust: [DEFAULT_RUST_VERSION]
        }
      },
      'runs-on': runs_on,
      steps: [
        { uses: 'actions/checkout@v2' },
        *INSTALL_RUBY_STEPS,
        *INSTALL_RUST_STEPS,
        *CACHE_GEMS_STEPS,
        *CACHE_CARGO_STEPS,
        *INSTALL_GEMS_STEPS,
        {
          name: 'Package gem',
          run: 'bundle exec rake build'
        },
        {
          name: 'Install packaged gem',
          run: "gem install pkg/str_metrics-#{StrMetrics::VERSION}.gem"
        },
        {
          name: 'Make sure gem is loadable',
          run: "ruby -rstr_metrics -e 'puts StrMetrics::VERSION'"
        }
      ]
    }
  }
end

def sanity_test_job(runs_on)
  {
    "sanity-test-#{runs_on}": {
      strategy: {
        matrix: {
          ruby: [DEFAULT_RUBY_VERSION],
          rust: [DEFAULT_RUST_VERSION]
        }
      },
      'runs-on': runs_on,
      steps: TEST_STEPS
    }
  }
end

CHECKS_WORKFLOW = {
  name: 'checks',
  on: %w[push],
  jobs: {
    test: {
      strategy: {
        matrix: {
          ruby: RUBY_VERSIONS,
          rust: RUST_VERSIONS
        }
      },
      'runs-on': 'ubuntu-latest',
      steps: TEST_STEPS
    },
    **RUBOCOP_JOB,
    **sanity_test_job('windows-latest'),
    **sanity_test_job('macos-latest'),
    **gem_install_job('ubuntu-latest'),
    **gem_install_job('macos-latest'),
    **gem_install_job('windows-latest')
  }
}.then(&method(:deep_stringify_keys)).freeze

File.open(File.expand_path(File.join(__dir__, 'checks.yml')), 'w') do |f|
  f.puts("# THIS IS A GENERATED FILE. DO NOT EDIT MANUALLY. EDIT & RUN gen_github_workflow.rb TO REGENERATE.\n")
  f.write(CHECKS_WORKFLOW.to_yaml)
end
