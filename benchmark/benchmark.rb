# frozen_string_literal: true

# Taken & modified from https://github.com/tonytonyjan/jaro_winkler
# Copyright (c) 2014 Jian Weihang
# MIT License

SAMPLES = {
  ascii: [
    %w[al al], %w[martha marhta], %w[jones johnson], %w[abcvwxyz cabvwxyz],
    %w[dwayne duane], %w[dixon dicksonx], %w[fvie ten]
  ].freeze
}.freeze

$LOAD_PATH << File.expand_path('../lib', __dir__)

require 'bundler'
Bundler.setup(:benchmark)

def gem_name_with_version(gem)
  "#{gem} (#{Gem.loaded_specs[gem].version})"
end

require 'benchmark'
require 'str_metrics'
require 'jaro_winkler'
require 'fuzzystringmatch'
require 'hotwater'
require 'amatch'

n = 100_000

Benchmark.bmbm do |x|
  x.report "str_metrics (#{`git rev-parse --short HEAD`.chop!})" do
    n.times { SAMPLES[:ascii].each { |str1, str2| StrMetrics::JaroWinkler.distance(str1, str2) } }
  end

  x.report gem_name_with_version('jaro_winkler') do
    n.times { SAMPLES[:ascii].each { |str1, str2| JaroWinkler.distance(str1, str2) } }
  end

  x.report gem_name_with_version('fuzzy-string-match') do
    jarow = FuzzyStringMatch::JaroWinkler.create(:native)
    n.times { SAMPLES[:ascii].each { |str1, str2| jarow.getDistance(str1, str2) } }
  end

  x.report gem_name_with_version('hotwater') do
    n.times { SAMPLES[:ascii].each { |str1, str2| Hotwater.jaro_winkler_distance(str1, str2) } }
  end

  x.report gem_name_with_version('amatch') do
    n.times { SAMPLES[:ascii].each { |str1, str2| Amatch::Jaro.new(str1).match(str2) } }
  end
end
