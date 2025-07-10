# frozen_string_literal: true

require_relative './policy_validator'

class PolicyOCR
  def initialize(file_path)
    @file_path = file_path
  end

  # This method parses the entries and returns a validation status
  def parse
    entries.map do |entry|
      digit_blocks = split_digits(entry)
      number = digit_blocks.map { |block| parse_digit(block) }.join
      validator = PolicyValidator.new(number)
      [number, validator.status]
    end
  end

  private

  def entries
    # check to see if file exists
    begin
      # return array of 3-line entry arrays, chomp removes /n
      lines = File.readlines(@file_path).map(&:chomp)
    rescue Errno::ENOENT
      raise ArgumentError, "Input file does not exist: #{@file_path}"
    end

    # raise an error if the file is empty
    raise ArgumentError, 'File is empty' if lines.empty?

    # Validate file format
    raise ArgumentError, 'File does not have a multiple of 4 lines' unless (lines.size % 4).zero?

    # Group lines into 4-line chunks and take the first 3 lines of each
    entries = []
    lines.each_slice(4) do |chunk|
      entry = chunk[0..2]
      # Only add valid entries (all 3 lines should have content and be 26-27 chars)
      if entry.all? { |line| line.length.between?(26, 27) } && entry.any? { |line| line.strip.length.positive? }
        entries << entry
      end
    end

    entries
  end

  # turn 3 lines into 9 digit blocks
  def split_digits(entry)
    (0..8).map do |position|
      entry.map do |line|
        start_pos = position * 3
        line[start_pos, 3]
      end
    end
  end

  # convert 3x3 block into string digit or "?"
  def parse_digit(block)
    digit_patterns = {

      [
        ' _ ',
        '| |',
        '|_|'
      ] => '0',

      [
        '   ',
        '  |',
        '  |'
      ] => '1',

      [
        ' _ ',
        ' _|',
        '|_ '
      ] => '2',

      [
        ' _ ',
        ' _|',
        ' _|'
      ] => '3',

      [
        '   ',
        '|_|',
        '  |'
      ] => '4',

      [
        ' _ ',
        '|_ ',
        ' _|'
      ] => '5',

      [
        ' _ ',
        '|_ ',
        '|_|'
      ] => '6',

      [
        ' _ ',
        '  |',
        '  |'
      ] => '7',

      [
        ' _ ',
        '|_|',
        '|_|'
      ] => '8',

      [
        ' _ ',
        '|_|',
        ' _|'
      ] => '9'
    }

    digit_patterns[block] || '?'
  end
end
