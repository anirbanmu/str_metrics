# frozen_string_literal: true

require 'ffi'

abort 'Rust compiler required (https://www.rust-lang.org/)' if `which rustc`.empty?

lib_name = FFI::Platform::OS == 'windows' ? 'str_metrics' : 'libstr_metrics'
src_path = File.expand_path(File.join(__dir__, 'target', 'release', "#{lib_name}.#{FFI::Platform::LIBSUFFIX}"))
dest_path = File.expand_path(File.join(__dir__, 'lib', 'str_metrics'))

if File::ALT_SEPARATOR
  src_path = src_path.gsub(File::SEPARATOR, File::ALT_SEPARATOR)
  dest_path = dest_path.gsub(File::SEPARATOR, File::ALT_SEPARATOR)
end

cp_cmd = if FFI::Platform::OS == 'windows'
           "xcopy \"#{src_path}\" \"#{dest_path}\\*\""
         else
           "cp \"#{src_path}\" \"#{dest_path}\""
         end

File.open('Makefile', 'wb') do |f|
  f.puts(<<~MKCONTENT)
    all:
    \tcargo rustc --release
    \t#{cp_cmd}
    clean:
    install:
    \tcargo clean
  MKCONTENT
end
