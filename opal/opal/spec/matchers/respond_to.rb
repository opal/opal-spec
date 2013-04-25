module OpalTest
  class RespondToMatcher < Matcher
    def initialize(expected)
      @expected = expected
    end

    def match(actual)
      unless actual.respond_to?(@expected)
        failure "Expected #{actual.inspect} (#{actual.class}) to respond to #{@expected}"
      end
    end
  end
end

class Object
  def respond_to(expected)
    OpalTest::RespondToMatcher.new expected
  end
end
