#!/usr/bin/env ruby

require_relative "archive"

require "colorize"
require "fileutils"
require "optparse"
require "tempfile"
require "test/unit"

class TestArchive < Test::Unit::TestCase
  def setup
    ENV["RUNNING_TESTS"] = "true"

    @source_dir = FileUtils.mkdir_p("test/test_source").join()
    puts "Created: #{@source_dir}" if @source_dir

    dest_dir = FileUtils.mkdir_p("test/test_destination").join()
    puts "Created: #{dest_dir}" if dest_dir

    test_file1 = FileUtils.touch("#{@source_dir}/test_file.txt").join()
    puts "Created: #{test_file1}" if test_file1

    test_file2 = FileUtils.touch("#{@source_dir}/test_file2.txt").join()
    puts "Created: #{test_file2}" if test_file2

    @test_dir = "#{@source_dir}/subdir/subsubdir/"

    FileUtils.mkdir_p(@test_dir).join()
    puts "Created: #{@test_dir}" if @test_dir

    @test_dir_file = FileUtils.touch("#{@test_dir}/test_file.txt").join()
    puts "Created: #{@test_dir_file}" if @test_dir_file

    # Expire the files
    File.utime(Time.now - 31 * 86400, Time.now - 31 * 86400, "#{@source_dir}/test_file2.txt")
    puts "Expired: #{@source_dir}/test_file2.txt"
  end

  def teardown
    FileUtils.remove_entry(@source_dir)
    FileUtils.remove_entry(@dest_dir)
  end

  def test_convert_to_absolute_path
    archive = Archive.new(validate_options: false)
    assert_equal(Dir.pwd, archive.convert_to_absolute_path(".\\"))
  end

  #   def test_get_expired_files
  #     archive = Archive.new(source: @source_dir, destination: @dest_dir, time: 30)
  #     expired_files = archive.get_expired_files(@source_dir)
  #     assert_include(expired_files, File.join(@source_dir, "test_file.txt"))
  #   end

  #   def test_move_file
  #     archive = Archive.new(source: @source_dir, destination: @dest_dir, time: 30)
  #     file_path = File.join(@source_dir, "test_file.txt")
  #     archive.move_file(file_path, @dest_dir)
  #     assert_false(File.exist?(file_path))
  #     assert_true(File.exist?(File.join(@dest_dir, "test_file.txt")))
  #   end
end
