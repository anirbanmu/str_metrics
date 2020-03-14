# frozen_string_literal: true

require 'ffi'
require 'str_metrics/version'

# Namespace for gem
module StrMetrics
  # Interface with Rust functions (not meant for public usage)
  module Native
    extend FFI::Library

    LIB_NAME = FFI::Platform::OS == 'windows' ? 'str_metrics' : 'libstr_metrics'
    ffi_lib File.expand_path(File.join(__dir__, 'str_metrics', "#{LIB_NAME}.#{FFI::Platform::LIBSUFFIX}"))

    attach_function :sorensen_dice_coefficient, %i[string string char], :double
    attach_function :levenshtein_distance, %i[string string char], :int64
    attach_function :damerau_levenshtein_distance, %i[string string char], :int64
    attach_function :jaro_similarity, %i[string string char], :double
    attach_function :jaro_winkler_similarity, %i[string string char int double double], :double
    attach_function :jaro_winkler_distance, %i[string string char int double double], :double
  end

  private_constant :Native

  refine String do
    def to_utf8
      encoding == Encoding::UTF_8 ? self : encode('UTF-8')
    end
  end

  using self # activates refinement

  # Namespace for Sorensen-Dice
  module SorensenDice
    def self.coefficient(a, b, ignore_case: false)
      Native.sorensen_dice_coefficient(a&.to_utf8, b&.to_utf8, ignore_case ? 1 : 0)
    end
  end

  # Namespace for Levenshtein
  module Levenshtein
    def self.distance(a, b, ignore_case: false)
      Native.levenshtein_distance(a&.to_utf8, b&.to_utf8, ignore_case ? 1 : 0)
    end
  end

  # Namespace for Damerau-Levenshtein
  module DamerauLevenshtein
    def self.distance(a, b, ignore_case: false)
      Native.damerau_levenshtein_distance(a&.to_utf8, b&.to_utf8, ignore_case ? 1 : 0)
    end
  end

  # Namespace for Jaro
  module Jaro
    def self.similarity(a, b, ignore_case: false)
      Native.jaro_similarity(a&.to_utf8, b&.to_utf8, ignore_case ? 1 : 0)
    end
  end

  # Namespace for Jaro-Winkler
  module JaroWinkler
    def self.similarity(
      a,
      b,
      ignore_case: false,
      prefix_scaling_factor: 0.1,
      prefix_scaling_bonus_threshold: 0.7
    )
      Native.jaro_winkler_similarity(
        a&.to_utf8,
        b&.to_utf8,
        ignore_case ? 1 : 0,
        4,
        prefix_scaling_factor,
        prefix_scaling_bonus_threshold
      )
    end

    def self.distance(
      a,
      b,
      ignore_case: false,
      prefix_scaling_factor: 0.1,
      prefix_scaling_bonus_threshold: 0.7
    )
      Native.jaro_winkler_distance(
        a&.to_utf8,
        b&.to_utf8,
        ignore_case ? 1 : 0,
        4,
        prefix_scaling_factor,
        prefix_scaling_bonus_threshold
      )
    end
  end
end
