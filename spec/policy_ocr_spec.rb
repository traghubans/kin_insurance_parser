require_relative '../lib/policy_ocr'

describe PolicyOCR do
  let(:parser) { PolicyOCR.new("spec/fixtures/sample.txt") }

  describe "#parse" do
    it "returns 9 entries from the sample file" do
      result = parser.parse
      expect(result.length).to eq(11)
    end

    it "parses each entry into [number, status] format" do
      result = parser.parse
    
      expect(result).to all(be_an(Array))
      expect(result).to all(have_attributes(length: 2))
    
      result.each do |number, status|
        expect(number).to match(/^[0-9?]{9}$/)
        expect([nil, "ERR", "ILL"]).to include(status)
      end
    end
    
  end

  describe "#entries" do
    it "extracts 3-line blocks from file" do
      entries = parser.send(:entries)
      expect(entries.length).to eq(11)
      expect(entries.first.length).to eq(3)
    end
  end

  describe "#split_digits" do
    it "splits a 3-line entry into 9 digit blocks" do
      entry = [
        " _  _  _  _  _  _  _  _  _ ",
        "| || || || || || || || || |",
        "|_||_||_||_||_||_||_||_||_|"
      ]
      blocks = parser.send(:split_digits, entry)
      expect(blocks.length).to eq(9)
      expect(blocks.first).to eq([" _ ", "| |", "|_|"])
    end
  end

  describe "#parse_digit" do
    {
      "0" => [" _ ", "| |", "|_|"],
      "1" => ["   ", "  |", "  |"],
      "2" => [" _ ", " _|", "|_ "],
      "3" => [" _ ", " _|", " _|"],
      "4" => ["   ", "|_|", "  |"],
      "5" => [" _ ", "|_ ", " _|"],
      "6" => [" _ ", "|_ ", "|_|"],
      "7" => [" _ ", "  |", "  |"],
      "8" => [" _ ", "|_|", "|_|"],
      "9" => [" _ ", "|_|", " _|"]
    }.each do |digit, block|
      it "parses digit #{digit}" do
        expect(parser.send(:parse_digit, block)).to eq(digit)
      end
    end

    it "returns '?' for unrecognized digit block" do
      unknown = ["???", "!!!", "..."]
      expect(parser.send(:parse_digit, unknown)).to eq("?")
    end
  end
end