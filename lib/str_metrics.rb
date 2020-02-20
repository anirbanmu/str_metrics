# frozen_string_literal: true

require 'ffi'
require 'str_metrics/version'

# Namespace for gem
module StrMetrics
  extend FFI::Library

  ffi_lib File.expand_path('./str_metrics/libstr_metrics.so', __dir__)

  attach_function :sorensen_dice_coefficient_ffi, :sorensen_dice_coefficient, %i[string string char], :double
  private_class_method :sorensen_dice_coefficient_ffi
  def self.sorensen_dice_coefficient(str_a, str_b, ignore_case: false)
    sorensen_dice_coefficient_ffi(str_a.encode('UTF-8'), str_b.encode('UTF-8'), ignore_case ? 1 : 0)
  end

  attach_function :jaro_similarity_ffi, :jaro_similarity, %i[string string char], :double
  private_class_method :jaro_similarity_ffi
  def self.jaro_similarity(str_a, str_b, ignore_case: false)
    jaro_similarity_ffi(str_a.encode('utf-8'), str_b.encode('utf-8'), ignore_case ? 1 : 0)
  end

  attach_function(
    :jaro_winkler_similarity_ffi,
    :jaro_winkler_similarity,
    %i[string string char int double double],
    :double
  )
  private_class_method :jaro_winkler_similarity_ffi
  def self.jaro_winkler_similarity(
    str_a,
    str_b,
    ignore_case: false,
    prefix_scaling_factor: 0.1,
    prefix_scaling_bonus_threshold: 0.7
  )
    jaro_winkler_similarity_ffi(
      str_a.encode('UTF-8'),
      str_b.encode('UTF-8'),
      ignore_case ? 1 : 0,
      4,
      prefix_scaling_factor,
      prefix_scaling_bonus_threshold
    )
  end

  attach_function :jaro_winkler_distance_ffi, :jaro_winkler_distance, %i[string string char int double double], :double
  private_class_method :jaro_winkler_distance_ffi
  def self.jaro_winkler_distance(
    str_a,
    str_b,
    ignore_case: false,
    prefix_scaling_factor: 0.1,
    prefix_scaling_bonus_threshold: 0.7
  )
    jaro_winkler_distance_ffi(
      str_a.encode('UTF-8'),
      str_b.encode('UTF-8'),
      ignore_case ? 1 : 0,
      4,
      prefix_scaling_factor,
      prefix_scaling_bonus_threshold
    )
  end

  attach_function :levenshtein_distance_ffi, :levenshtein_distance, %i[string string char], :int
  private_class_method :levenshtein_distance_ffi
  def self.levenshtein_distance(str_a, str_b, ignore_case: false)
    levenshtein_distance_ffi(str_a.encode('UTF-8'), str_b.encode('UTF-8'), ignore_case ? 1 : 0)
  end

  attach_function :damerau_levenshtein_distance_ffi, :damerau_levenshtein_distance, %i[string string char], :int
  private_class_method :damerau_levenshtein_distance_ffi
  def self.damerau_levenshtein_distance(str_a, str_b, ignore_case: false)
    damerau_levenshtein_distance_ffi(str_a.encode('UTF-8'), str_b.encode('UTF-8'), ignore_case ? 1 : 0)
  end

  # Namespace for Sorensen-Dice
  module SorensenDice
    def self.coefficient(*args)
      ::StrMetrics.sorensen_dice_coefficient(*args)
    end
  end

  # Namespace for Jaro
  module Jaro
    def self.similarity(*args)
      ::StrMetrics.jaro_similarity(*args)
    end
  end

  # Namespace for Jaro-Winkler
  module JaroWinkler
    def self.similarity(*args)
      ::StrMetrics.jaro_winkler_similarity(*args)
    end

    def self.distance(*args)
      ::StrMetrics.jaro_winkler_distance(*args)
    end
  end

  # Namespace for Levenshtein
  module Levenshtein
    def self.distance(*args)
      ::StrMetrics.levenshtein_distance(*args)
    end
  end

  # Namespace for Damerau-Levenshtein
  module DamerauLevenshtein
    def self.distance(*args)
      ::StrMetrics.damerau_levenshtein_distance(*args)
    end
  end
end
