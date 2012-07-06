module Spec
  class Matcher
    def initialize actual
      @actual = actual
    end

    def failure message
      raise Spec::ExpectationNotMetError, message
    end
  end

  class PositiveOperatorMatcher < Matcher
    def == expected
      if @actual == expected
        true
      else
        failure "expected: #{expected.inspect}, got: #{@actual.inspect} (using ==)."
      end
    end
  end

  class NegativeOperatorMatcher < Matcher
    def == expected
      if @actual == expected
        failure "expected: #{expected.inspect} not to be #{@actual.inspect} (using ==)."
      end
    end
  end

  class BeKindOfMatcher < Matcher
    def match expected
      unless expected.kind_of? @actual
        failure "expected #{expected.inspect} to be a kind of #{@actual}, not #{expected.class}."
      end
    end
  end

  class BeNilMatcher < Matcher
    def match expected
      unless expected.nil?
        failure "expected #{expected.inspect} to be nil."
      end
    end
  end

  class BeTrueMatcher < Matcher
    def match expected
      unless expected == true
        failure "expected #{expected.inspect} to be true."
      end
    end
  end

  class BeFalseMatcher < Matcher
    def match expected
      unless expected == false
        failure "expected #{expected.inspect} to be false."
      end
    end
  end

  class EqualMatcher < Matcher
    def match expected
      unless expected.equal? @actual
        failure "expected #{@actual.inspect} to be the same as #{expected.inspect}."
      end
    end

    def not_match expected
      if expected.equal? @actual
        failure "expected #{@actual.inspect} not to be equal to #{expected.inspect}."
      end
    end
  end

  class RaiseErrorMatcher < Matcher
    def match block
      should_raise = false
      begin
        block.call
        should_raise = true
      rescue => e
      end

      if should_raise
        failure "expected #{@actual} to be raised, but nothing was."
      end
    end
  end
end
