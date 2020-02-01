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
    kw_string = !kw.empty? ? " with options { #{kw} }" : ''
    "comparing \"#{input[0]}\", \"#{input[1]}\"#{kw_string} yields #{output}"
  end
end

RSpec.describe StrMetrics do
  it 'has a version number' do
    expect(StrMetrics::VERSION).not_to be nil
  end

  describe 'SorensenDice' do
    describe '.coefficient' do
      [
        Case.new('night', 'night', 1),
        Case.new('night', 'niGHt', 1, ignore_case: true),
        Case.new('night', 'nacht', 0.25),
        Case.new('nightht', 'hta', 0.25), # Make sure there's no issue with double counting
        Case.new('münchen', 'munch', 0.4), # Make sure there's no assumption about ASCII
        Case.new('mÜnchen', 'münch', 0.8, ignore_case: true),
        Case.new('অআইঈউ', 'অঝইঈউ', 0.5)
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
      ].each do |c|
        it c.test_str do
          expect(StrMetrics::Jaro.similarity(*c.input, **c.keywords)).to be_within(0.0001).of(c.output)
        end
      end
    end
  end

  # describe 'JaroWinkler' do
  #   describe '.similarity' do
  #     [
  #       Case.new('dwayne', 'duane', Rational(37, 45)),
  #       Case.new('dwAyne', 'duane', Rational(7, 10)),
  #       Case.new('Dwayne', 'duAnE', Rational(37, 45), ignore_case: true),
  #       Case.new('dixon', 'dicksonx', Rational(23, 30)),
  #       Case.new('jellyfish', 'smellyfish', Rational(121, 135)),
  #       Case.new('martha', 'marhta', Rational(17, 18)),
  #       Case.new('arnab', 'raanb', Rational(13, 15)),
  #       Case.new('münchen', 'munch', Rational(83, 105)), # Make sure there's no assumption about ASCII
  #       Case.new('mÜnchen', 'münch', Rational(19, 21), ignore_case: true), # Make sure ignore_case works with non-ASCII
  #       Case.new('অআইঈউ', 'অঝইঈউ', Rational(13, 15))
  #     ].each do |c|
  #       it c.test_str do
  #         expect(StrMetrics::JaroWinkler.similarity(*c.input, **c.keywords).to_r.rationalize(0.00001)).to eq(c.output)
  #       end
  #     end
  #   end
  # end
end
