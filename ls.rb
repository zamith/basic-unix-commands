#!/usr/bin/env ruby

require_relative "extensions/case_is"
require_relative "extensions/case_symbol"
require_relative "extensions/colors"
require "optparse"

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ls.rb [options]"

  opts.on("-G", "Enable colorized output.") do |colorized|
    options[:colorized] = colorized
  end

  opts.on("-1", "(The numeric digit `one`.)  Force output to be one entry per line.") do |opt|
    options[:one_per_line] = opt
  end
end.parse!

unless $stdout.isatty
  options[:one_per_line] = true
end

def show?(filename)
  !filename.start_with?(".")
end

def colored(dir, filename)
  file = File::Stat.new("#{dir}/#{filename}")
  case file
  when is(:directory?) then filename.light_blue
  else filename
  end
end

directory_to_list = ARGV[0] || "."
$, = " "

output = Dir.foreach(directory_to_list).map do |filename|
  next unless show?(filename)

  case options
  when :colorized then colored(directory_to_list, filename)
  else filename
  end
end.compact!

case options
when :one_per_line then puts(*output)
else print(*output, "\n")
end
