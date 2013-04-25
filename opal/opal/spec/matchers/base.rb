module OpalTest
  class Matcher
    def initialize(actual)
      @actual = actual
    end

    def failure(message)
      raise Spec::ExpectationNotMetError, message
    end
  end
end
