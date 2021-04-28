# frozen_string_literal: true

require 'benchmark'
require 'str_metrics'

tests = [
  %w[München Munich],
  %w[Berlin Munich],
  ['Some rather long string', 'Another rather long string']
]
long_words_tests = [
  [
    'The Jaro–Winkler distance uses a prefix scale p which gives more favourable ratings to strings that match from the beginning for a set prefix length ll ll .', 'Another rather long string'
  ],
  [
    'The Jaro–Winkler distance uses a prefix scale p which gives more favourable ratings to strings that match from the beginning for a set prefix length ll ll .', 'This report shows the user CPU time, system CPU time, the sum of the user and system CPU times, and the elapsed real time. The unit of time is seconds.'
  ]
]
label_width = 'str_metrics, longer words: StrMetrics::JaroWinkler'.length

Benchmark.bm(label_width) do |x|
  x.report('str_metrics, short words: StrMetrics::JaroWinkler') do
    50_000.times do
      tests.each do |words|
        StrMetrics::JaroWinkler.distance(words[0], words[1])
      end
    end
  end
  x.report('ruby, short words: DidYouMean::JaroWinkler') do
    50_000.times do
      tests.each do |words|
        DidYouMean::JaroWinkler.distance(words[0], words[1])
      end
    end
  end
end

Benchmark.bm(label_width) do |x|
  x.report('str_metrics, longer words: StrMetrics::JaroWinkler') do
    50_000.times do
      long_words_tests.each do |words|
        StrMetrics::JaroWinkler.distance(words[0], words[1])
      end
    end
  end
  x.report('ruby, longer words: DidYouMean::JaroWinkler') do
    50_000.times do
      long_words_tests.each do |words|
        DidYouMean::JaroWinkler.distance(words[0], words[1])
      end
    end
  end
end

Benchmark.bm(label_width) do |x|
  x.report('str_metrics, short words: StrMetrics::Levenshtein') do
    50_000.times do
      tests.each do |words|
        StrMetrics::Levenshtein.distance(words[0], words[1])
      end
    end
  end
  x.report('ruby, short words: DidYouMean::Levenshtein') do
    50_000.times do
      tests.each do |words|
        DidYouMean::Levenshtein.distance(words[0], words[1])
      end
    end
  end
end

Benchmark.bm(label_width) do |x|
  x.report('str_metrics, longer words: StrMetrics::Levenshtein') do
    50_000.times do
      long_words_tests.each do |words|
        StrMetrics::Levenshtein.distance(words[0], words[1])
      end
    end
  end
  x.report('ruby, longer words:  DidYouMean::Levenshtein') do
    50_000.times do
      long_words_tests.each do |words|
        DidYouMean::Levenshtein.distance(words[0], words[1])
      end
    end
  end
end
