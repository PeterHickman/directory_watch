#!/usr/bin/env ruby
# frozen_string_literal: true

class Opts
  attr_reader :arguments

  def initialize(commands)
    @options = {}
    @arguments = []

    parse(commands)
  end

  def option(name, type, default = nil)
    if @options.key?(name)
      case type
      when 'integer'
        @options[name].to_i
      when 'float'
        @options[name].to_f
      when 'boolean'
        @options[name] == 'true'
      when 'string'
        @options[name]
      else
        raise "Unknown option type [#{type}]"
      end
    elsif default.nil?
      raise "Missing option [#{name}]"
    else
      default
    end
  end

  private

  def parse(commands)
    end_of_options = false

    while commands.any?
      x = commands.shift

      if end_of_options
        @arguments << x
      elsif x == '--'
        end_of_options = true
      elsif x.start_with?('--')
        y = commands.shift
        @options[x] = y
      else
        @arguments << x
        end_of_options = true
      end
    end
  end
end

o = Opts.new(ARGV)

path = o.option('--path', 'string')
sleep_for = o.option('--sleep', 'integer', 5)

unless path.include?('*') || path.include?('?')
  raise 'Path includes no wildcards (* or ?). Did you put it in quotes?'
end

STDOUT.sync = true

seen = []
found = []

loop do
  ##
  # See what files have been removed
  ##
  seen.each do |filename|
    next if File.exist?(filename)

    seen.delete(filename)
  end

  found.each do |filename|
    STDOUT.puts filename
    seen << filename
  end

  ##
  # Find the new files and report them
  ##
  found.clear
  Dir[path].each do |filename|
    next if seen.include?(filename)

    found << filename
  end

  sleep sleep_for
end
