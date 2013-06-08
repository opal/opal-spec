module OpalSpec
  class Matcher
    attr_reader :actual, :expected

    def initialize expected = nil
      @expected = expected
    end

    def positive_match? actual
      @actual = actual

      unless match expected, actual
        raise OpalSpec::ExpectationNotMetError, failure_message_for_should
      end
    end

    def negative_match? actual
      @actual = actual

      if match expected, actual
        raise OpalSpec::ExpectationNotMetError, failure_message_for_should_not
      end
    end

    def failure_message_for_should
      "expected: #{expected.inspect}, actual: #{actual.inspect} (#{matcher_name}) [should]."
    end

    def failure_message_for_should_not
      "expected: #{expected.inspect}, actual: #{actual.inspect} (#{matcher_name}) [should_not]."
    end
  end

  class PositiveOperatorMatcher < Matcher
    def == expected
      if @expected == expected
        true
      else
        failure "expected: #{expected.inspect}, got: #{@expected.inspect} (using ==)."
      end
    end
  end

  class NegativeOperatorMatcher < Matcher
    def == expected
      if @expected == expected
        failure "expected: #{expected.inspect} not to be #{@expected.inspect} (using ==)."
      end
    end
  end
end
