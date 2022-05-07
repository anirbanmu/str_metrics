# frozen_string_literal: true

class Case
  attr_reader :input, :output, :keywords

  def initialize(a, b, output, **options)
    @input = [a, b]
    @keywords = options
    @output = output
  end

  def test_str
    kw = keywords.map { |k, v| "#{k}: #{v}" }.join(', ')
    kw_string = kw.empty? ? '' : " with options { #{kw} }"

    msg = "comparing \"#{input[0] ? input[0].encode('UTF-8') : 'nil'}\""
    msg += " (#{input[0].encoding})" if input[0]
    msg += ', '
    msg += "\"#{input[1] ? input[1].encode('UTF-8') : 'nil'}\""
    msg += " (#{input[1].encoding})" if input[1]
    msg + "#{kw_string} yields #{output}"
  end
end

def account_for_encodings(cases)
  encodings = %w[ASCII UTF-8 UTF-16 UTF-32 BIG5]
  encodings = encodings.product(encodings)

  cases.each.with_object([]) do |c, arr|
    encodings.each do |enc0, enc1|
      # begin needed for supporting older rubies
      begin # rubocop:disable Style/RedundantBegin
        arr.push(Case.new(c.input[0].encode(enc0), c.input[1].encode(enc1), c.output, **c.keywords))
      rescue Encoding::UndefinedConversionError # rubocop:disable Lint/SuppressedException
      end
    end
  end
end

INT64_MAX = 9_223_372_036_854_775_807

RSpec.describe StrMetrics do
  it 'has a version number' do
    expect(StrMetrics::VERSION).not_to be_nil
  end

  describe 'SorensenDice' do
    describe '.coefficient' do
      [
        Case.new(nil, nil, 0),
        Case.new(nil, 'abcd', 0),
        Case.new('abc', nil, 0),
        *account_for_encodings(
          [
            Case.new('', '', 0),
            Case.new('a', '', 0),
            Case.new('a', 'ab', 0),
            Case.new('abcde', 'a', 0),
            Case.new('night', 'night', 1),
            Case.new('abc', 'def', 0),
            Case.new('night', 'niGHt', 1, ignore_case: true),
            Case.new('night', 'nacht', 0.25),
            Case.new('nightht', 'hta', 0.25), # Make sure there's no issue with double counting
            Case.new('münchen', 'munch', 0.4), # Make sure there's no assumption about ASCII
            Case.new('mÜnchen', 'münch', 0.8, ignore_case: true),
            Case.new('অআইঈউ', 'অঝইঈউ', 0.5)
          ]
        )
      ].each do |c|
        it c.test_str do
          expect(StrMetrics::SorensenDice.coefficient(*c.input, **c.keywords)).to be_within(0.0001).of(c.output)
        end
      end
    end
  end

  describe 'Jaro' do
    describe '.similarity' do
      [
        Case.new(nil, nil, 0.0),
        Case.new(nil, 'ab', 0.0),
        Case.new('abcd', nil, 0.0),
        *account_for_encodings(
          [
            Case.new('', '', 0.0),
            Case.new('a', '', 0.0),
            Case.new('', 'a', 0.0),
            Case.new('a', 'a', 1.0),
            Case.new('a', 'ab', 0.83333),
            Case.new('ab', 'a', 0.83333),
            Case.new('ab', 'ab', 1.0),
            Case.new('hello', 'hello', 1.0),
            Case.new('abc', 'def', 0.0),
            Case.new('dwayne', 'duane', 0.82222),
            Case.new('dwAyne', 'duane', 0.7),
            Case.new('Dwayne', 'duAnE', 0.82222, ignore_case: true),
            Case.new('dixon', 'dicksonx', 0.76666),
            Case.new('jellyfish', 'smellyfish', 0.89629),
            Case.new('martha', 'marhta', 0.94444),
            Case.new('arnab', 'raanb', 0.86666),
            Case.new('münchen', 'munch', 0.79047), # Make sure there's no assumption about ASCII
            Case.new('mÜnchen', 'münch', 0.90476, ignore_case: true), # Make sure ignore_case works with non-ASCII
            Case.new('অআইঈউ', 'অঝইঈউ', 0.86666)
          ]
        )
      ].each do |c|
        it c.test_str do
          expect(StrMetrics::Jaro.similarity(*c.input, **c.keywords)).to be_within(0.0001).of(c.output)
        end
      end
    end
  end

  describe 'JaroWinkler' do
    [
      Case.new(nil, nil, 0.0),
      Case.new(nil, 'ab', 0.0),
      Case.new('abcd', nil, 0.0),
      *account_for_encodings(
        [
          Case.new('', '', 0.0),
          Case.new('', 'a', 0.0),
          Case.new('a', '', 0.0),
          Case.new('a', 'a', 1.0),
          Case.new('a', 'ab', 0.85),
          Case.new('ab', 'a', 0.85),
          Case.new('ab', 'ab', 1.0),
          Case.new('hello', 'hello', 1.0),
          Case.new('abc', 'def', 0.0),
          Case.new('dwayne', 'duane', 0.84000),
          Case.new('dwAyne', 'duane', 0.73000),
          Case.new('Dwayne', 'duAnE', 0.84000, ignore_case: true),
          Case.new('dixon', 'dicksonx', 0.81333),
          Case.new('jellyfish', 'smellyfish', 0.89629),
          Case.new('martha', 'marhta', 0.96111),
          Case.new('arnab', 'raanb', 0.86666),
          Case.new('münchen', 'munch', 0.81142), # Make sure there's no assumption about ASCII
          Case.new('mÜnchen', 'münch', 0.94285, ignore_case: true), # Make sure ignore_case works with non-ASCII
          Case.new('অআইঈউ', 'অঝইঈউ', 0.88),
          Case.new('y̆', 'y', 0.0), # Compared as graphemes so no match at all
          Case.new('abcdxxxxxxxxxxxxxxxxxxxxxxxxxx', 'dcbayyyyyyyyyyyyyyyyyyyyyyyyyy', 0.25555) # Check transpositions
        ]
      )
    ].tap do |cases|
      describe '.similarity' do
        cases.each do |c|
          it c.test_str do
            expect(StrMetrics::JaroWinkler.similarity(*c.input, **c.keywords)).to be_within(0.0001).of(c.output)
          end
        end
      end

      describe '.distance' do
        cases.map { |c| Case.new(c.input[0], c.input[1], 1.0 - c.output, **c.keywords) }.each do |c|
          it c.test_str do
            expect(StrMetrics::JaroWinkler.distance(*c.input, **c.keywords)).to be_within(0.0001).of(c.output)
          end
        end
      end
    end
  end

  describe 'Levenshtein' do
    describe '.distance' do
      [
        Case.new(nil, nil, INT64_MAX),
        Case.new(nil, 'ab', INT64_MAX),
        Case.new('abcd', nil, INT64_MAX),
        *account_for_encodings(
          [
            Case.new('', '', 0),
            Case.new('', 'a', 1),
            Case.new('bb', '', 2),
            Case.new('', 'bb', 2),
            Case.new('a', 'b', 1),
            Case.new('a', 'a', 0),
            Case.new('ab', 'ab', 0),
            Case.new('y̆', 'y', 1),
            Case.new('hello', 'hello', 0),
            Case.new('kitten', 'sitting', 3),
            Case.new('kItTen', 'sittinG', 3, ignore_case: true),
            Case.new('GUMBO', 'GAMBOL', 2),
            Case.new('Honda', 'Hyundai', 3),
            Case.new('Sleepy', 'Dopey', 4)
          ]
        )
      ].each do |c|
        it c.test_str do
          expect(StrMetrics::Levenshtein.distance(*c.input, **c.keywords)).to eq(c.output)
        end
      end
    end
  end

  describe 'DamerauLevenshtein' do
    describe '.distance' do
      [
        Case.new(nil, nil, INT64_MAX),
        Case.new(nil, 'ab', INT64_MAX),
        Case.new('abcd', nil, INT64_MAX),
        *account_for_encodings(
          [
            Case.new('', '', 0),
            Case.new('', 'a', 1),
            Case.new('bb', '', 2),
            Case.new('', 'bb', 2),
            Case.new('a', 'b', 1),
            Case.new('a', 'a', 0),
            Case.new('ab', 'ab', 0),
            Case.new('y̆', 'y', 1),
            Case.new('hello', 'hello', 0),
            Case.new('Hello', 'hello', 1),
            Case.new('Hello', 'hello', 0, ignore_case: true),
            Case.new('a cat', 'a tc', 2),
            Case.new('a cat', 'a abct', 2),
            Case.new('smtih', 'smith', 1),
            Case.new('ⓕⓞⓤⓡ', 'ⓕⓤⓞⓡ', 1),
            Case.new('1234567890', '1324576809', 3),
            Case.new('ogogle', 'googel', 2),
            Case.new('abcd', 'acb', 2)
          ]
        )
      ].each do |c|
        it c.test_str do
          expect(StrMetrics::DamerauLevenshtein.distance(*c.input, **c.keywords)).to eq(c.output)
        end
      end
    end
  end
end
