require 'opaltest/unit'
require 'minitest/spec'

module OpalTest
  class PositiveOperatorMatcher
    def initialize(actual)
      @actual = actual
    end

    def ==(expected)
      MiniTest::Spec.current.assert_equal expected, @actual
    end
  end

  class BeNilMatcher
    def match(actual)
      MiniTest::Spec.current.assert actual.nil?
    end
  end

  class BeTrueMatcher
    def match(actual)
      MiniTest::Spec.current.assert true == actual
    end
  end

  class BeFalseMatcher
    def match(actual)
      MiniTest::Spec.current.assert false == actual
    end
  end

  class BeKindOfMatcher
    def initialize(expected)
      @expected = expected
    end

    def match(actual)
      MiniTest::Spec.current.assert_kind_of @expected, actual
    end
  end

  module Exceptions
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
  include OpalTest::Exceptions
end

