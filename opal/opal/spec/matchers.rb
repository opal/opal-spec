module OpalSpec
  class Matcher
    def initialize(*args)
      @args = args
    end

    def inspect
      "#<#{matcher_name} matcher>"
    end

    def positive_match?(subject)
      @subject = subject

      unless match?
        raise OpalSpec::ExpectationNotMetError, failure_message
      end
    end

    def negative_match?(subject)
      @subject = subject

      if match?
        raise OpalSpec::ExpectationNotMetError, negative_failure_message
      end
    end

    def failure_message
      "expected #{@args.first.inspect}, actual: #{@subject} [#{matcher_name}]"
    end

    def negative_failure_message
      "expected #{@args.first.inspect} to not match #{@subject} [#{matcher_name}]"
    end
  end

  class PositiveOperatorMatcher < Matcher
    def initialize(subject)
      @subject = subject
    end

    def matcher_name
      "positive operator"
    end

    def ==(actual)
      @actual = actual

      unless @subject == @actual
        raise Opal::Spec::ExpectationNotMetError, failure_message
      end
    end

    def failure_message
      "expected #{@actual.inspect}, but got: #{@subject.inspect} (using ==)."
    end
  end

  class NegativeOperatorMatcher < Matcher
    def initialize(subject)
      @subject = subject
    end

    def matcher_name
      "negative operator"
    end

    def ==(actual)
      @actual = actual

      if @subject == @actual
        raise Opal::Spec::ExpectationNotMetError, negative_failure_message
      end
    end

    def negative_failure_message
      "expected #{@actual.inspect} not to be: #{@subject.inspect} (using ==)."
    end
  end
end
