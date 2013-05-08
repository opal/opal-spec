module OpalSpec
  class Matcher
    def initialize(actual)
      @actual = actual
    end

    def failure(message)
      raise OpalSpec::ExpectationNotMetError, message
    end
  end
end
