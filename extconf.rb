# frozen_string_literal: true

abort 'Rust compiler required (https://www.rust-lang.org/)' if `which rustc`.empty?

File.open('Makefile', 'wb') do |f|
  f.puts(<<~MKCONTENT)
    all:
    \tbundle --deployment --path vendor/bundle
    \tbundle exec rake
    clean:
    install:
    \trm -r vendor/bundle target
  MKCONTENT
end
