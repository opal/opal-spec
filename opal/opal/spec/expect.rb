module OpalSpec
  class ExpectationTarget
    def initialize(value)
      @value = value
    end

    def to(matcher = nil, &block)
      no_matcher! unless matcher
      matcher.positive_match? @value
    end

    def to_not(matcher = nil)
      no_matcher! unless matcher
      matcher.negative_match? @value
    end

    def no_matcher!
      raise ArgumentError, 'The expect syntax requires a matcher'
    end
  end
end
