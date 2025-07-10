# frozen_string_literal: true

require_relative '../lib/policy_validator'

describe PolicyValidator do
  it 'loads' do
    expect(PolicyValidator).to be_a Class
  end

  describe '#status' do
    it 'returns nil for a valid policy number' do
      validator = PolicyValidator.new('457508000')
      expect(validator.status).to be_nil
    end

    it 'returns ERR for a number with a bad checksum' do
      validator = PolicyValidator.new('664371495')
      expect(validator.status).to eq('ERR')
    end

    it 'returns ILL for a number with illegible characters' do
      validator = PolicyValidator.new('86110??36')
      expect(validator.status).to eq('ILL')
    end

    it 'returns ERR for all digits but fails checksum' do
      validator = PolicyValidator.new('111111111')
      expect(validator.status).to eq('ERR')
    end

    it 'returns nil for a number that passes the checksum' do
      validator = PolicyValidator.new('345882865')
      expect(validator.status).to be_nil
    end
  end
end
