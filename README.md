# PolicyOCR - Insurance Policy Number Parser

A Ruby-based OCR (Optical Character Recognition) system designed to parse insurance policy numbers from text files containing 7-segment display representations.

## Objective

Convert insurance policy numbers from ASCII art representations (7-segment displays) into readable digit strings, with error detection for illegible or invalid numbers.

## User Stories Tackled
- User Story 1
- User Story 2
- User Story 3

## Quick Start

### Prerequisites
- Ruby 2.7 or higher
- Bundler gem

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd kin_insurance_parser
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Run tests**
   ```bash
   bundle exec rspec
   ```
4. **Run Application**
   There are three sample files you could run, you can decide which one to run by editing the input path in bin/run.rb
   The options you have are sample.txt, sample2.txt, and sample3.txt
   Then run in your terminal below:

   ```bash
   ruby bin/run.rb
   ```

## File Format
```

### Input File Format

Each policy number is represented by 4 lines:
- **Lines 1-3**: 7-segment display representation (27 characters each)
- **Line 4**: Blank line (separator)

Example:
```
 _  _  _  _  _  _  _  _  _ 
| || || || || || || || || |
|_||_||_||_||_||_||_||_||_|
                           
```

### Output Format

The parser returns an array of arrays, where each inner array contains:
- **Position 0**: 9-digit policy number (may contain "?" for illegible digits)
- **Position 1**: Status (`nil` for valid, `"ERR"` for checksum error, `"ILL"` for illegible)

Example output:
```ruby
[
  ["123456789", nil],      # Valid policy number
  ["12345678?", "ILL"],    # Illegible (contains "?")
  ["123456789", "ERR"]     # Checksum error
]
```
The formatter will take this and return in the output.txt file:
123456789
12345678? ILL
123456789 ERR

## Testing

### Run All Tests
```bash
bundle exec rspec
```

### Run Specific Test File
```bash
bundle exec rspec spec/policy_ocr_spec.rb
```

### Test Coverage

The test suite covers:
- File format validation
- Digit pattern recognition (0-9)
- Error handling for invalid files
- Entry parsing and digit splitting
- Output format validation
- Edge cases and malformed input

## How It Works

### 1. File Processing
- Reads the input file line by line
- Validates file format (must be multiple of 4 lines)
- Groups lines into 4-line chunks

### 2. Entry Extraction
- Extracts 3-line entries (ignoring blank separator lines)
- Filters for valid entries (26-27 characters per line)
- Validates entry structure

### 3. Digit Recognition
- Splits each 3-line entry into 9 digit blocks (3 characters each)
- Maps each 3x3 block to its corresponding digit using pattern matching
- Returns "?" for unrecognized patterns

### 4. Status Determination
- **Valid**: All digits recognized, checksum passes
- **ILL**: Contains "?" characters (illegible)
- **ERR**: All digits recognized but checksum fails
