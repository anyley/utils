module Utils
  module Callbacks
    def before_action *methods, &blk
      @@___new_methods ||= []
      @@___callbacks ||= {}
      @@___callbacks[blk] = []
      methods.each do |m|
        @@___callbacks[blk] << m
      end
    end

    def method_added name
      return if @@___new_methods.include? name
      @@___callbacks.each do |blk, methods|
        if methods.include? name
          hidden_original = "___#{name}".to_sym
          @@___new_methods.concat [hidden_original, name]
          alias_method hidden_original, name
          define_method name do
            blk.call
            self.send hidden_original.to_sym
          end
          @@___callbacks[blk].delete name
        end
      end
    end
  end
end

class FilterTest
  extend Utils::Callbacks

  before_action :baz do
    puts "before 1"
  end

  before_action :baz2 do
    puts "before 2"
  end

  def baz
    puts "baz 1"
  end

  def baz2
    puts "baz 2"
  end
end

# ft = FilterTest.new
# ft.baz
# ft.baz2

# before 1
# baz 1
# before 2
# baz 2
