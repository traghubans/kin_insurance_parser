# frozen_string_literal: true

require_relative '../lib/policy_formatter'

describe PolicyFormatter do
  let(:output_path) { 'spec/tmp/output.txt' }

  before(:each) do
    FileUtils.mkdir_p('spec/tmp')
  end

  after(:each) do
    File.delete(output_path) if File.exist?(output_path)
  end

  it 'writes each policy number to a new line with optional status' do
    data = [
      ['457508000', nil],
      ['664371495', 'ERR'],
      ['86110??36', 'ILL']
    ]

    formatter = PolicyFormatter.new(output_path)
    formatter.write(data)

    lines = File.readlines(output_path).map(&:strip)

    expect(lines.length).to eq(3)
    expect(lines[0]).to eq('457508000')
    expect(lines[1]).to eq('664371495 ERR')
    expect(lines[2]).to eq('86110??36 ILL')
  end

  it 'does not add extra whitespace when status is nil' do
    data = [['123456789', nil]]
    formatter = PolicyFormatter.new(output_path)
    formatter.write(data)

    line = File.read(output_path).strip
    expect(line).to eq('123456789')
  end
end
