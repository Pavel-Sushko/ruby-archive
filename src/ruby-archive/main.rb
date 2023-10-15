#!/usr/bin/env ruby

require_relative "archive"
require_relative "utils"

require "colorize"
require "optparse"

# Main class that handles the program
class Main
	def initialize(code_args = nil, validate_options = true)
        # Initialize options
        @options = initialize_options
	end

	def initialize_options
		options = {} # Hash that stores the command line options

		OptionParser.new do |opt|
			opt.banner = "Usage: archive.rb -s <source_dir> -d <destination_dir> [options] [-h for help]"
			opt.on("-s", "--source SOURCE", String, "Source directory") { |o| options[:source] = o }
			opt.on("-d", "--destination DESTINATION", String, "Destination directory") { |o| options[:destination] = o }
			opt.on("-t", "--time TIME", Integer, "Expiration time in days. Default is 30") { |o| options[:time] = o }
			opt.on("-v", "--verbose", "Verbose output") { |o| options[:verbose] = o }
			opt.on("-h", "--help", "Displays this help") { |o| options[:help] = o }
			opt.on("-T", "--test", "Test mode. Does not move files. Automatically sets verbose mode") do |o|
				options[:test] = o
				options[:verbose] = o
			end

            @help = opt
		end.parse!

        # If help is specified, or if no options are specified, display help and exit
        if options.empty? || options[:help]
            puts @help
            exit
        end

        # If source or destination is not specified, throw an error stating which one exactly is missing
        if !options[:source] then raise OptionParser::MissingArgument, "Source directory is not specified" end
        if !options[:destination] then raise OptionParser::MissingArgument, "Destination directory is not specified" end

        # Set default values
        options[:time] ||= 30 # Default expiration time is 30 days
        options[:time] *= 86400 # Convert expiration time to seconds

        # Convert directories to absolute paths
        options[:source] = Utils.convert_to_absolute_path(options[:source])
        options[:destination] = Utils.convert_to_absolute_path(options[:destination])

        return options
	end

    def main
        # Create the required directories
        Utils.create_directories(@options[:source], @options[:destination])

        # Get expired files
        expired_files = Utils.get_expired_files(@options[:source], @options[:time])

        # Archive files
        Archive.archive_files(expired_files, @options[:source], @options[:destination], @options[:time])

        # Clean up empty directories in the source directory
        # Utils.clean_up(@options[:source], @options[:destination])
    end
end

if __FILE__ == $0
    Main.new.main
end
