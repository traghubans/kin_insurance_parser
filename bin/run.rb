require_relative '../lib/policy_ocr'
require_relative '../lib/policy_formatter'

input_path = "spec/fixtures/sample.txt"
output_path = "output.txt"

# Parse OCR input
ocr = PolicyOCR.new(input_path)
results = ocr.parse # => [ [number, status], ... ]

# Format and write to file
formatter = PolicyFormatter.new(output_path)
formatter.write(results)

puts "Wrote formatted results to #{output_path}"