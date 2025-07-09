class PolicyFormatter
    def initialize(output_path)
        @output_path = output_path
    end

    # Output the status to a file
    def write(entries)
        File.open(@output_path, "w") do |file|
            entries.each do |number, status|
                puts number
                line = [number, status].compact.join(" ")
                file.puts(line)
            end
        end
    end

end