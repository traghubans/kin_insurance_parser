require_relative '../lib/policy_ocr'
require 'tempfile'

describe PolicyOCR do
  it "loads" do
    expect(PolicyOCR).to be_a Class
  end

  it 'loads the sample.txt' do
    expect(fixture('sample').lines.count).to eq(44)
  end

  describe '#entries' do
    it 'returns array of 3-line entry arrays' do
      parser = PolicyOCR.new("spec/fixtures/sample.txt")
      entries = parser.send(:entries)

      expect(entries).to be_an(Array)
      expect(entries.length).to eq(9)
      expect(entries.first).to be_an(Array)
      expect(entries.first.length).to eq(3)
      expect(entries.first.all? { |line| line.length.between?(26, 27) }).to be true
    end

    it 'raises error for invalid file format' do
      # Create a temporary file with invalid format
      temp_file = Tempfile.new(['invalid', '.txt'])
      temp_file.write("line 1\nline 2\nline 3\n") # Not multiple of 4
      temp_file.close

      expect {
        parser = PolicyOCR.new(temp_file.path)
        parser.send(:entries)
      }.to raise_error(ArgumentError, "File does not have a multiple of 4 lines")

      temp_file.unlink
    end
  end

  describe '#split_digits' do
    it 'splits 3-line entry into 9 digit blocks' do
      parser = PolicyOCR.new("spec/fixtures/sample.txt")
      entry = [
        " _  _  _  _  _  _  _  _  _ ",
        "| || || || || || || || || |",
        "|_||_||_||_||_||_||_||_||_|"
      ]
      
      digit_blocks = parser.send(:split_digits, entry)
      
      expect(digit_blocks).to be_an(Array)
      expect(digit_blocks.length).to eq(9)
      expect(digit_blocks.first).to be_an(Array)
      expect(digit_blocks.first.length).to eq(3)
      expect(digit_blocks.first).to eq([" _ ", "| |", "|_|"])
    end
  end

  describe '#parse_digit' do
    it 'recognizes digit 0' do
      parser = PolicyOCR.new("spec/fixtures/sample.txt")
      block = [" _ ", "| |", "|_|"]
      expect(parser.send(:parse_digit, block)).to eq("0")
    end

    it 'recognizes digit 1' do
      parser = PolicyOCR.new("spec/fixtures/sample.txt")
      block = ["   ", "  |", "  |"]
      expect(parser.send(:parse_digit, block)).to eq("1")
    end

    it 'recognizes digit 2' do
      parser = PolicyOCR.new("spec/fixtures/sample.txt")
      block = [" _ ", " _|", "|_ "]
      expect(parser.send(:parse_digit, block)).to eq("2")
    end

    it 'recognizes digit 8' do
      parser = PolicyOCR.new("spec/fixtures/sample.txt")
      block = [" _ ", "|_|", "|_|"]
      expect(parser.send(:parse_digit, block)).to eq("8")
    end

    it 'returns "?" for unrecognized pattern' do
      parser = PolicyOCR.new("spec/fixtures/sample.txt")
      block = ["xxx", "yyy", "zzz"]
      expect(parser.send(:parse_digit, block)).to eq("?")
    end
  end

  describe '#parse' do
    it 'parses the first entry correctly' do
      parser = PolicyOCR.new("spec/fixtures/sample.txt")
      result = parser.parse
      
      expect(result).to be_an(Array)
      expect(result.length).to eq(9)
      expect(result.first).to be_a(String)
      expect(result.first.length).to eq(9)
    end

    it 'parses all entries and returns array of strings' do
      parser = PolicyOCR.new("spec/fixtures/sample.txt")
      result = parser.parse
      
      expect(result).to be_an(Array)
      expect(result.length).to eq(9)
      result.each do |entry|
        expect(entry).to be_a(String)
        expect(entry.length).to eq(9)
        expect(entry).to match(/^[0-9?]+$/)
      end
    end
  end
end
