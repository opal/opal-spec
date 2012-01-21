module OpalSpec
  class ExpectationNotMetError < StandardError; end

  module Expectations
    def should matcher = nil
      if matcher
        matcher.match self
      else
        OpalSpec::PositiveOperatorMatcher.new self
      end
    end

    def should_not matcher = nil
      if matcher
        matcher.not_match self
      else
        OpalSpec::NegativeOperatorMatcher.new self
      end
    end

    def be_kind_of expected
      OpalSpec::BeKindOfMatcher.new expected
    end

    def be_nil
      OpalSpec::BeNilMatcher.new nil
    end

    def be_true
      OpalSpec::BeTrueMatcher.new true
    end

    def be_false
      OpalSpec::BeFalseMatcher.new false
    end

    def equal expected
      OpalSpec::EqualMatcher.new expected
    end

    def raise_error expected
      OpalSpec::RaiseErrorMatcher.new expected
    end
  end
end

class Object
  include OpalSpec::Expectations
end
