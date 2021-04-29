# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'ffi'
require 'fileutils'

RSpec::Core::RakeTask.new(:spec)

task :rust_build do
  `cargo rustc --release`

  lib_name = FFI::Platform::OS == 'windows' ? 'str_metrics' : 'libstr_metrics'
  src = File.expand_path(File.join(__dir__, 'target', 'release', "#{lib_name}.#{FFI::Platform::LIBSUFFIX}"))
  dest = File.expand_path(File.join(__dir__, 'lib', 'str_metrics'))
  FileUtils.cp(src, dest, verbose: true)
end

task spec: :rust_build

task bench: :rust_build do
  ruby File.expand_path(File.join(__dir__, 'bench', 'rust_vs_ruby.rb'))
end
