# frozen_string_literal: true

require 'active_support/core_ext/string'
require 'pry'

class Thing
  attr_accessor :name

  def initialize(name = nil)
    @name = name
    @things = []
  end

  def method_missing(method_name, *args, &block)
    command = method_name.to_s

    case
    when command.include?('?')
      ([name] + @things.map(&:name)).find { |name| name == command.delete('?') }.present?
    when command == 'is_a'
      self.class.new.tap { |thing| @things << thing }
    when command == 'is_not_a'
      self.class.new
    when command == 'has' || command == 'having'
      count = args.first
      count.times { @things << self.class.new }
      self
    else
      if @things.blank?
        @name = command.singularize
      elsif @things.any? { |thing| thing.name.nil? }
        last_things = @things.select { |thing| thing.name.nil? }
        if last_things.count == 1
          last_things.last.tap { |thing| thing.name = command.singularize }
        else
          last_things.each { |thing| thing.name = command.singularize }
        end
      else
        founded_things = @things.select { |thing| thing.name == command.singularize }
        founded_things.count == 1 ? founded_things.last : founded_things
      end
    end
  end
end
