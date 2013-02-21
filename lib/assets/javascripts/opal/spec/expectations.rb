module OpalTest
  class ExpectationNotMetError < StandardError; end

  module Expectations
    def should matcher = nil
      if matcher
        matcher.match self
      else
        PositiveOperatorMatcher.new self
      end
    end

    def should_not matcher = nil
      if matcher
        matcher.not_match self
      else
        NegativeOperatorMatcher.new self
      end
    end

    def be_kind_of expected
      BeKindOfMatcher.new expected
    end

    def be_nil
      BeNilMatcher.new nil
    end

    def be_true
      BeTrueMatcher.new true
    end

    def be_false
      BeFalseMatcher.new false
    end

    def eq(expected)
      EqlMatcher.new expected
    end

    def equal expected
      EqualMatcher.new expected
    end

    def raise_error expected
      RaiseErrorMatcher.new expected
    end
  end
end

class Object
  include OpalTest::Expectations
end
