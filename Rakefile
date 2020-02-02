# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
# require 'helix_runtime/build_task'

# HelixRuntime::BuildTask.new
RSpec::Core::RakeTask.new(:spec)

task :rust_build do
  `cargo rustc --release`
  `mv -f ./target/release/libstr_metrics.so ./lib/str_metrics`
end

task spec: :rust_build
