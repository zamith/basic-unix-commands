#!/usr/bin/env ruby

require_relative "extensions/case_is"
require_relative "extensions/case_symbol"
require_relative "extensions/colors"
require "optparse"

def parse_options!(argv)
  $options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: ls.rb [options]"

    opts.on("-1", "(The numeric digit `one`.) Force output to be one entry per line.") do |opt|
      $options[:one_per_line] = opt
    end

    opts.on("-A", "List all entries except for `.` and `..`. Always set for the super-user.") do |opt|
      $options[:list_all_but_dot_and_double_dot] = opt
    end

    opts.on("-a", "Include directory entries whose names begin with a dot (`.`).") do |opt|
      $options[:list_all] = opt
    end

    opts.on("-C", "Force multi-column output; this is the default when output is to a terminal.") do |opt|
      $options[:multi_column] = opt
    end

    opts.on("-G", "Enable colorized output.") do |opt|
      $options[:colorized] = opt
    end
  end.parse! argv
end

class ListsFile
  def initialize(filename:, directory: ".", options: {})
    @filename = filename
    @directory = directory
    @options = options
  end

  def prepare_file_for_listing
    return unless show?

    case options
    when :colorized then colored
    else filename
    end
  end

  def show?
    case options
    when :list_all_but_dot_and_double_dot then filename !~ /^(\.\.|\.)$/
    when :list_all then true
    else !filename.start_with?(".")
    end
  end

  def colored
    file = File::Stat.new("#{directory}/#{filename}")
    case file
    when is(:directory?) then filename.light_blue
    when is(:executable?) then filename.red
    else filename
    end
  end

  private

  attr_reader :filename, :directory, :options
end

def set_default_options_for_output
  unless $options[:multi_column] || $stdout.isatty
    $options[:one_per_line] = true
  end
end

def add_padding(filename, max)
  filename + " " * (max - filename.size)
end

def run_ls(directory_or_file = ".", options: ARGV)
  parse_options!(options)
  set_default_options_for_output
  directory_or_file ||= "."

  files = if File.directory?(directory_or_file)
            Dir.foreach(directory_or_file).map do |filename|
              ListsFile.new(filename: filename, directory: directory_or_file, options: $options).prepare_file_for_listing
            end.compact
          else
            ListsFile.new(filename: directory_or_file, options: $options).prepare_file_for_listing
          end

  $, = " "
  output = Array(files)
  max = output.max_by(&:size).size
  case $options
  when :one_per_line then puts(*output)
  else print(*output.map{|filename| add_padding(filename, max)}, "\n")
  end
end

if $0 == __FILE__
  run_ls(ARGV[0])
end

