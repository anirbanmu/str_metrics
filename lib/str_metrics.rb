# frozen_string_literal: true

require 'helix_runtime'

begin
  require 'str_metrics/native'
rescue LoadError
  puts 'Failed to load the native part of str_metrics. Please run `rake build`'
  raise
end

require 'str_metrics/version'

class StrMetrics
  class Error < StandardError; end

  # These just do proper namespacing, manage parameters & redirect into rust implementation
  module SorensenDice
    def self.coefficient(str_a, str_b, ignore_case: false)
      ::StrMetricsImpl.sorensen_dice_coefficient(str_a, str_b, ignore_case)
    end
  end

  module Jaro
    def self.similarity(str_a, str_b, ignore_case: false)
      ::StrMetricsImpl.jaro_similarity(str_a, str_b, ignore_case)
    end
  end

  module JaroWinkler
    def self.similarity(str_a, str_b, ignore_case: false, prefix_scaling_factor: 0.1)
      ::StrMetricsImpl.jaro_winkler_similarity(str_a, str_b, ignore_case, 4, prefix_scaling_factor)
    end

    def self.distance(str_a, str_b, ignore_case: false, prefix_scaling_factor: 0.1)
      ::StrMetricsImpl.jaro_winkler_distance(str_a, str_b, ignore_case, 4, prefix_scaling_factor)
    end
  end
end
