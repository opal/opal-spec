module Spec
  class ExpectationNotMetError < StandardError; end

  module Expectations
    def should matcher = nil
      if matcher
        matcher.match self
      else
        Spec::PositiveOperatorMatcher.new self
      end
    end

    def should_not matcher = nil
      if matcher
        matcher.not_match self
      else
        Spec::NegativeOperatorMatcher.new self
      end
    end

    def be_kind_of expected
      Spec::BeKindOfMatcher.new expected
    end

    def be_nil
      Spec::BeNilMatcher.new nil
    end

    def be_true
      Spec::BeTrueMatcher.new true
    end

    def be_false
      Spec::BeFalseMatcher.new false
    end

    def equal expected
      Spec::EqualMatcher.new expected
    end

    def raise_error expected
      Spec::RaiseErrorMatcher.new expected
    end
  end
end

class Object
  include Spec::Expectations
end
