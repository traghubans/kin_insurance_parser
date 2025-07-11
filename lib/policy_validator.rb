# frozen_string_literal: true

class PolicyValidator
  def initialize(policy_number)
    @policy_number = policy_number
  end

  # check if a number is valid & assign a status
  def status
    return 'ILL' if @policy_number.include?('?')
    return 'ERR' unless checksum_calculator?

    nil
  end

  private

  # private method to calculate the checksum
  def checksum_calculator?
    # cast the policy number
    checksumArray = @policy_number.chars.map(&:to_i)
    checksumResult = checksumArray.each_with_index.sum do |num, i|
      num * (9 - i)
    end

    (checksumResult % 11).zero?
  end
end
