# frozen_string_literal: true

require 'ffi'
require 'str_metrics/version'

module StrMetrics
  extend FFI::Library

  ffi_lib File.expand_path('./str_metrics/libstr_metrics.so', __dir__)

  attach_function :sorensen_dice_coefficient_c, %i[string string char], :double
  private_class_method :sorensen_dice_coefficient_c
  def self.sorensen_dice_coefficient(str_a, str_b, ignore_case: false)
    sorensen_dice_coefficient_c(str_a, str_b, ignore_case ? 1 : 0)
  end

  attach_function :jaro_similarity_c, %i[string string char], :double
  private_class_method :jaro_similarity_c
  def self.jaro_similarity(str_a, str_b, ignore_case: false)
    jaro_similarity_c(str_a, str_b, ignore_case ? 1 : 0)
  end

  attach_function :jaro_winkler_similarity_c, %i[string string char int double], :double
  private_class_method :jaro_winkler_similarity_c
  def self.jaro_winkler_similarity(str_a, str_b, ignore_case: false, prefix_scaling_factor: 0.1)
    jaro_winkler_similarity_c(str_a, str_b, ignore_case ? 1 : 0, 4, prefix_scaling_factor)
  end

  attach_function :jaro_winkler_distance_c, %i[string string char int double], :double
  private_class_method :jaro_winkler_distance_c
  def self.jaro_winkler_distance(str_a, str_b, ignore_case: false, prefix_scaling_factor: 0.1)
    jaro_winkler_distance_c(str_a, str_b, ignore_case ? 1 : 0, 4, prefix_scaling_factor)
  end

  module SorensenDice
    def self.coefficient(*args)
      ::StrMetrics.sorensen_dice_coefficient(*args)
    end
  end

  module Jaro
    def self.similarity(*args)
      ::StrMetrics.jaro_similarity(*args)
    end
  end

  module JaroWinkler
    def self.similarity(*args)
      ::StrMetrics.jaro_winkler_similarity(*args)
    end

    def self.distance(*args)
      ::StrMetrics.jaro_winkler_distance(*args)
    end
  end
end
