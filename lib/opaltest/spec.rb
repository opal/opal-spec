require 'opaltest/unit'

module Kernel
  def describe desc, &block
    cls = OpalTest::Spec.create desc
    cls.class_eval(&block)
    cls
  end
end

module OpalTest
  class Spec < MiniTest::Unit::TestCase
    def self.current
      @@current_spec
    end

    def initialize name
      #super name
      @__name__ = name
      @@current_spec = self
    end

    def self.before type = :each, &block
      raise "unsupported before type: #{type}" unless type == :each

      add_setup_hook {|tc| tc.instance_eval(&block) }
    end

    def self.after type = :each, &block
      raise "unsupported after type: #{type}" unless type == :each

      add_teardown_hook {|tc| tc.instance_eval(&block) }
    end

    def self.it desc = "anonymouse", &block
      block ||= proc { skip "(no tests defined)" }

      @specs ||= 0
      @specs += 1

      name = "test_#{@specs}_#{desc.gsub(/\W+/, '_').downcase}"

      define_method name, &block
    end

    def self.create name
      cls = Class.new(self)
      cls.instance_eval do
        @name = name
        @desc = name
      end

      cls
    end

    def self.to_s
      @name
    end

    def self.desc
      @desc
    end

    #class << self
    #  attr_reader :desc
    #end
  end

  class PositiveOperatorMatcher
    def initialize(actual)
      @actual = actual
    end

    def ==(expected)
      OpalTest::Spec.current.assert_equal expected, @actual
    end
  end

  class NegativeOperatorMatcher
    def initialize(actual)
      @actual = actual
    end

    def ==(expected)
      OpalTest::Spec.current.refute_equal expected, @actual
    end
  end

  class BeNilMatcher
    def match(actual)
      OpalTest::Spec.current.assert actual.nil?
    end
  end

  class BeTrueMatcher
    def match(actual)
      OpalTest::Spec.current.assert true == actual
    end
  end

  class BeFalseMatcher
    def match(actual)
      OpalTest::Spec.current.assert false == actual
    end
  end

  class BeKindOfMatcher
    def initialize(expected)
      @expected = expected
    end

    def match(actual)
      OpalTest::Spec.current.assert_kind_of @expected, actual
    end
  end

  class EqualMatcher
    def initialize(expected)
      @expected = expected
    end

    def match(actual)
      OpalTest::Spec.current.assert_same @expected, actual
    end

    def not_match(actual)
      OpalTest::Spec.current.refute_same @expected, actual
    end
  end

  class RaiseErrorMatcher
    def initialize(expected)
      @expected = expected
    end

    def match(actual)
      OpalTest::Spec.current.assert_raises @expected, &actual
    end
  end

  module Expectations
    def should(matcher = nil)
      if matcher
        matcher.match(self)
      else
        OpalTest::PositiveOperatorMatcher.new(self)
      end
    end

    def should_not(matcher = nil)
      if matcher
        matcher.not_match(self)
      else
        OpalTest::NegativeOperatorMatcher.new(self)
      end
    end

    def be_nil
      OpalTest::BeNilMatcher.new
    end

    def be_true
      OpalTest::BeTrueMatcher.new
    end

    def be_false
      OpalTest::BeFalseMatcher.new
    end

    def be_kind_of(expected)
      OpalTest::BeKindOfMatcher.new(expected)
    end

    def equal(expected)
      OpalTest::EqualMatcher.new(expected)
    end

    def raise_error(expected)
      OpalTest::RaiseErrorMatcher.new(expected)
    end
  end
end

class Object
  include OpalTest::Expectations
end

module ScratchPad
  def self.clear
    @record = nil
  end

  def self.record(arg)
    @record = arg
  end

  def self.<<(arg)
    @record << arg
  end

  def self.recorded
    @record
  end
end

class Object
  def mock(obj)
    Object.new
  end

  def it_behaves_like(*a)

  end
end
