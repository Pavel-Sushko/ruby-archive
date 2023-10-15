#!/usr/bin/env ruby

require_relative "test_archive"

require "optparse"

# Class that handles the tests
class TestRunner
  # Initializes the test class
  def initialize
    @options = {} # Hash that stores the command line options

    OptionParser.new do |opt|
      opt.on("-v", "--verbose", "Verbose output") { |o| @options[:verbose] = o }
      opt.on("-h", "--help", "Displays this help") do |o|
        puts opt.help
        exit
      end
    end.parse!
  end

  # Runs the tests
  def run
    # If verbose option is specified, set verbose mode for tests
    Test::Unit::UI::Console::TestRunner.run(TestArchive, @options[:verbose])
  end
end
