# frozen_string_literal: true

require_relative '../lib/policy_ocr'

describe PolicyOCR do
  let(:parser) { PolicyOCR.new('spec/fixtures/sample.txt') }
  let(:empty_path) { 'spec/tmp/empty.txt' }

  before(:each) do
    FileUtils.mkdir_p('spec/tmp')
    File.write(empty_path, '')
  end

  after(:each) do
    File.delete(empty_path) if File.exist?(empty_path)
  end

  describe '#parse' do
    it 'returns 9 entries from the sample file' do
      result = parser.parse
      expect(result.length).to eq(11)
    end

    it 'parses each entry into [number, status] format' do
      result = parser.parse

      expect(result).to all(be_an(Array))
      expect(result).to all(have_attributes(length: 2))

      result.each do |number, status|
        expect(number).to match(/^[0-9?]{9}$/)
        expect([nil, 'ERR', 'ILL']).to include(status)
      end
    end
    
  end

  describe '#entries' do
    it 'raises an error for empty input file' do
      expect do
        PolicyOCR.new(empty_path).send(:entries)
      end.to raise_error(ArgumentError, 'File is empty')
    end

    it 'extracts 3-line blocks from file' do
      entries = parser.send(:entries)
      expect(entries.length).to eq(11)
      expect(entries.first.length).to eq(3)
    end

    it 'raises an error if the input file does not exist' do
      nonexistent_path = 'spec/tmp/not_a_file.txt'

      expect do
        PolicyOCR.new(nonexistent_path).send(:entries)
      end.to raise_error(ArgumentError, /does not exist/)
    end
  end

  describe '#split_digits' do
    it 'splits a 3-line entry into 9 digit blocks' do
      entry = [
        ' _  _  _  _  _  _  _  _  _ ',
        '| || || || || || || || || |',
        '|_||_||_||_||_||_||_||_||_|'
      ]
      blocks = parser.send(:split_digits, entry)
      expect(blocks.length).to eq(9)
      expect(blocks.first).to eq([' _ ', '| |', '|_|'])
    end
  end

  describe '#parse_digit' do
    {
      '0' => [' _ ', '| |', '|_|'],
      '1' => ['   ', '  |', '  |'],
      '2' => [' _ ', ' _|', '|_ '],
      '3' => [' _ ', ' _|', ' _|'],
      '4' => ['   ', '|_|', '  |'],
      '5' => [' _ ', '|_ ', ' _|'],
      '6' => [' _ ', '|_ ', '|_|'],
      '7' => [' _ ', '  |', '  |'],
      '8' => [' _ ', '|_|', '|_|'],
      '9' => [' _ ', '|_|', ' _|']
    }.each do |digit, block|
      it "parses digit #{digit}" do
        expect(parser.send(:parse_digit, block)).to eq(digit)
      end
    end

    it "returns '?' for unrecognized digit block" do
      unknown = ['???', '!!!', '...']
      expect(parser.send(:parse_digit, unknown)).to eq('?')
    end
  end
end
