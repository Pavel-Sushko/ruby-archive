#!/usr/bin/env ruby

require "fileutils"

class Utils
    # Converts a path to an absolute path, removes trailing slashes, and converts backslashes to forward slashes
    def self.convert_to_absolute_path(path)
        return File.expand_path(path).gsub(/\/$/, "").gsub(/\\$/, "/")
    end

    # Cleans up empty directories in the source directory
    def self.clean_up(source, destination)
		# Recursively delete empty directories in source directory
		Dir.children(source).each do |sub|
			sub_path = File.join(source, sub)

			if File.directory?(sub_path)
				clean_up(sub_path)
			end
		end

		if Dir.empty?(source) && source != @options[:source]
			FileUtils.rmdir(source)
		end
	end

	# Creates the required directories
	def self.create_directories(source, destination)
		# Create each directory in the source directory within the destination directory
	    Dir.glob("#{source}/**/*/").each do |dir|
			relative_dir = dir.sub(/^#{source}/, "")
			new_dir = File.join(destination, relative_dir)

            FileUtils.mkdir_p(new_dir) unless Dir.exist?(new_dir)
		end
	end

    # Returns an array of files that have not been modified in the last X days
	def self.get_expired_files(source, days_to_archive)
	    expired_files = [] # Array that stores the expired files

		# Iterate through all files in the source directory
		Dir.children(source).each do |file|
			file_path = [source, file].join("/") # Full path to file

			if File.directory?(file_path) # If file is a directory, call this function recursively
				expired_files.concat(get_expired_files(file_path, days_to_archive))
			elsif (Time.now - File.atime(file_path)) / 86400 > days_to_archive
				expired_files.push(file_path)
			end
		end

		return expired_files
	end

    # Moves a file to a destination directory
	def self.move_file(file, source, destination)
		# Extract subdirectories from file path from source directory
		directory_of_file = File.dirname(file)
        directory_path = directory_of_file == source ? "" : file.gsub(source, "").gsub(/^\//, "").gsub(/\/[^\/]+$/, "")

		# Create directory structure in destination directory
		FileUtils.mkdir_p([destination, directory_path].join("/"))

		# Move file to destination directory
		FileUtils.mv(file, [destination, directory_path].join("/"))

		# If old directory is empty, delete it, go up until we find a non-empty directory
		while Dir.empty?(file.gsub(/\/[^\/]+$/, "")) && file.gsub(/\/[^\/]+$/, "") != source
			FileUtils.rmdir(file.gsub(/\/[^\/]+$/, ""))
			file = file.gsub(/\/[^\/]+$/, "")
		end
	end
end
