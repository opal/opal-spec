module OSpec
  class ExpectationNotMetError < StandardError; end

  module Expectations
    def should matcher = nil
      if matcher
        matcher.match self
      else
        OSpec::PositiveOperatorMatcher.new self
      end
    end

    def should_not matcher = nil
      if matcher
        matcher.not_match self
      else
        OSpec::NegativeOperatorMatcher.new self
      end
    end

    def be_kind_of expected
      OSpec::BeKindOfMatcher.new expected
    end

    def be_nil
      OSpec::BeNilMatcher.new nil
    end

    def be_true
      OSpec::BeTrueMatcher.new true
    end

    def be_false
      OSpec::BeFalseMatcher.new false
    end

    def equal expected
      OSpec::EqualMatcher.new expected
    end

    def raise_error expected
      OSpec::RaiseErrorMatcher.new expected
    end
  end
end

class Object
  include OSpec::Expectations
end
