#!/usr/bin/env ruby

require_relative "extensions/case_is"
require_relative "extensions/case_symbol"
require_relative "extensions/colors"
require "optparse"

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
end.parse!

unless $options[:multi_column] || $stdout.isatty
  $options[:one_per_line] = true
end

def show?(filename)
  case $options
  when :list_all_but_dot_and_double_dot then filename !~ /^(\.\.|\.)$/
  when :list_all then true
  else !filename.start_with?(".")
  end
end

def colored(dir, filename)
  file = File::Stat.new("#{dir}/#{filename}")
  case file
  when is(:directory?) then filename.light_blue
  when is(:executable?) then filename.red
  else filename
  end
end

def add_padding(filename, max)
  filename + " " * (max - filename.size)
end

directory_to_list = ARGV[0] || "."

output = Dir.foreach(directory_to_list).map do |filename|
  next unless show?(filename)

  case $options
  when :colorized then colored(directory_to_list, filename)
  else filename
  end
end.compact

$, = " "
max = output.max_by(&:size).size
case $options
when :one_per_line then puts(*output)
else print(*output.map{|filename| add_padding(filename, max)}, "\n")
end
