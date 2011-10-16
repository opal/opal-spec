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
      super name
      @@current_spec = self
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

    def to_s
      @name
    end

    class << self
      attr_reader :desc
    end
  end

  class PositiveOperatorMatcher
    def initialize(actual)
      @actual = actual
    end

    def ==(expected)
      OpalTest::Spec.current.assert_equal expected, @actual
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

  module Expectations
    def should(matcher)
      if matcher
        matcher.match(self)
      else
        OpalTest::PositiveOperatorMatcher.new(self)
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
  end
end

class Object
  include OpalTest::Expectations
end

