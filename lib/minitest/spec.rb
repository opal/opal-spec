require 'minitest/unit'

class Module

  def infect_an_assertion(meth, new_name, dont_flip = false)
    define_method(new_name) do |*args|
      @@current_spec.__send__ meth, self, *args
    end
  end
end

module Kernel

  def describe(desc, additional_desc = nil, &block)
    stack = MiniTest::Spec.describe_stack
    # name = [stack.last, desc, additional_desc].compact.join("::")
    name = desc
    sclas = stack.last || (if Class === self && self.is_a?(MiniTest::Spec)
                            self
                          else
                            MiniTest::Spec.spec_type desc
                          end)

    puts sclas.inspect
    cls = sclas.create name, desc

    stack.push cls
    cls.class_eval(&block)
    stack.pop
    cls
  end
end

class MiniTest::Spec < MiniTest::Unit::TestCase

  def self.spec_type(desc)
    MiniTest::Spec
  end

  @describe_stack = []
  def self.describe_stack
    @describe_stack
  end

  def self.current
    @@current_spec
  end

  def initialize(name)
    super name
    @@current_spec = self
  end

  def self.nuke_test_methods!
    # need to remove methods...
  end

  def self.it(desc = "anonymous", &block)
    block ||= proc { skip "(no tests defined)" }

    @specs ||= 0
    @specs += 1

    name = "test_#{@specs}_#{desc.gsub(/\W+/, '_').downcase}"

    define_method name, &block
  end


  def self.create(name, desc)
    cls = Class.new(self)
    cls.instance_eval do
      @name = name
      @desc = desc

      nuke_test_methods!
    end

    cls
  end

end

module MiniTest::Exceptions

  infect_an_assertion :assert_equal, :must_equal
end

class Object
  include MiniTest::Exceptions
end

