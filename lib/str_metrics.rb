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
    def self.coefficient(a, b, ignore_case: false)
      ::StrMetricsImpl.sorensen_dice_coefficient(a, b, ignore_case)
    end
  end
end
