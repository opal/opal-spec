module Opal
  module Spec
    class ExpectationNotMetError < StandardError; end

    module Expectations
      def should matcher = nil
        if matcher
          matcher.match self
        else
          Opal::Spec::PositiveOperatorMatcher.new self
        end
      end

      def should_not matcher = nil
        if matcher
          matcher.not_match self
        else
          Opal::Spec::NegativeOperatorMatcher.new self
        end
      end

      def be_kind_of expected
        Opal::Spec::BeKindOfMatcher.new expected
      end

      def be_nil
        Opal::Spec::BeNilMatcher.new nil
      end

      def be_true
        Opal::Spec::BeTrueMatcher.new true
      end

      def be_false
        Opal::Spec::BeFalseMatcher.new false
      end

      def eq(expected)
        Opal::Spec::EqlMatcher.new expected
      end

      def equal expected
        Opal::Spec::EqualMatcher.new expected
      end

      def raise_error expected
        Opal::Spec::RaiseErrorMatcher.new expected
      end
    end
  end
end

class Object
  include Opal::Spec::Expectations
end
