class PolicyOCR
    def initialize(file_path)
      @file_path = file_path
    end
  
    def parse
      entries.map do |entry|
        digit_blocks = split_digits(entry)
        digit_blocks.map { |block| parse_digit(block) }.join
      end
    end
  
    private
  
    def entries
      # Subtask 1: return array of 3-line entry arrays
      lines = File.readlines(@file_path).map(&:rstrip)
      
      # Validate file format
      raise ArgumentError, "File does not have a multiple of 4 lines" unless lines.size % 4 == 0
      
      # Group lines into 4-line chunks and take the first 3 lines of each
      entries = []
      lines.each_slice(4) do |chunk|
        entry = chunk[0..2]
        # Only add valid entries (all 3 lines should have content and be 26-27 chars)
        if entry.all? { |line| line.length.between?(26, 27) } && entry.any? { |line| line.strip.length > 0 }
          entries << entry
        end
      end
      
      entries
    end

    def split_digits(entry)
      # Subtask 2: turn 3 lines into 9 digit blocks
      (0..8).map do |position|
        entry.map do |line|
          start_pos = position * 3
          line[start_pos, 3]
        end
      end
    end

    def parse_digit(block)
      # Subtask 3: convert 3x3 block into string digit or "?"
      digit_patterns = {
        # 0
        [
            " _ ", 
            "| |", 
            "|_|"
        ] => "0",
        # 1
        [
            "   ", 
            "  |", 
            "  |"
        ] => "1",
        # 2
        [
            " _ ", 
            " _|", 
            "|_ "
        ] => "2",
        # 3
        [
            " _ ", 
            " _|", 
            " _|"
        ] => "3",
        # 4
        [
            "   ", 
            "|_|", 
            "  |"
        ] => "4",
        # 5
        [
            " _ ",
            "|_ ", 
            " _|"
        ] => "5",
        # 6
        [
            " _ ", 
            "|_ ", 
            "|_|"
        ] => "6",
        # 7
        [
            " _ ", 
            "  |", 
            "  |"
        ] => "7",
        # 8
        [
            " _ ", 
            "|_|", 
            "|_|"
        ] => "8",
        # 9
        [
            " _ ", 
            "|_|", 
            " _|"
        ] => "9"
      }
      
      digit_patterns[block] || "?"
    end
  end