class PolicyValidator
    def initialize(policy_number)
        @policy_number = policy_number
    end

    # Task 1: We want to check if a number is valid & assign a status
    def status 
        return "ILL" if @policy_number.include?("?")
        return "ERR" unless checksum_calculator?
        nil
    end


    private 

    # We want a private method to calculate the checksum
    # Checksum is calculated by 
    def checksum_calculator?
        # cast the policy number
        checksumArray = @policy_number.chars.map(&:to_i)
        checksumResult = checksumArray.each_with_index.sum {
            |num, i|
            num * (9 - i)
        }

        checksumResult % 11 == 0
    end

end
