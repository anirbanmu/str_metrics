# frozen_string_literal: true

abort 'Rust compiler required (https://www.rust-lang.org/)' if `which rustc`.empty?

File.open('Makefile', 'wb') do |f|
  f.puts(<<~MKCONTENT)
    all:
    \tcargo rustc --release -- -C link-args=-Wl,-undefined,dynamic_lookup
    \tmv ./target/release/libstr_metrics.so ./lib/str_metrics
    clean:
    install:
    \trm -r target ./lib/str_metrics/libstr_metrics.so
  MKCONTENT
end
