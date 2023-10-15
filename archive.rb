#!/usr/bin/env ruby

# Moves files that have not been modified in the last X days to a specified directory
# Usage: archive.rb -s <source_dir> -d <destination_dir> [-t <days_to_archive>] [-h for help]

require_relative "utils"

# Class that handles the archiving of files
class Archive
	# Archives files
	def self.archive_files(expired_files, source, destination, days_to_archive)
        expired_files.each do |file|
            # Create the required directories
            Utils.create_directories(file, destination)

            # Move file to destination directory
            Utils.move_file(file, source, destination)
        end
	end
end
