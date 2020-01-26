# frozen_string_literal: true

RSpec.describe StrMetrics do
  it 'has a version number' do
    expect(StrMetrics::VERSION).not_to be nil
  end

  describe 'SorensenDice' do
    describe '.coefficient' do
      class Case
        attr_reader :input, :output, :keywords

        def initialize(a, b, output, ignore_case: false)
          @input = [a, b]
          @keywords = { ignore_case: ignore_case }
          @output = output
        end

        def test_str
          kw = keywords.map { |k, v| "#{k}: #{v}" }.join(', ')
          "comparing \"#{input[0]}\", \"#{input[1]}\" with options { #{kw} } yields #{output}"
        end

        def call_func
          StrMetrics::SorensenDice.coefficient(*input, **keywords)
        end
      end

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
          expect(c.call_func).to eq(c.output)
        end
      end
    end
  end
end
