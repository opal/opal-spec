module OpalSpec
  class ExpectationNotMetError < StandardError; end

  module Expectations
  end

  def self.matcher(name, &block)
    klass = Class.new(Matcher, &block)

    klass.define_method(:matcher_name) { name }

    Expectations.define_method(name) do |*args|
      klass.new(*args)
    end
  end

  matcher :be_nil do
    def match?
      @subject.nil?
    end

    def failure_message
      "expected #{@subject.inspect} to be nil."
    end

    def negative_failure_message
      "expected #{@subject.inspect} to not be nil."
    end
  end

  matcher :be_true do
    def match?
      @subject == true
    end

    def failure_message
      "expected #{@subject.inspect} to be true."
    end
  end

  matcher :be_false do
    def match?
      @subject == false
    end

    def failure_message
      "expected #{@subject.inspect} to be false."
    end
  end

  matcher :be_kind_of do
    def initialize(klass)
      @klass = klass
    end

    def match?
      @subject.kind_of?(@klass)
    end

    def failure_message
      "expected #{@subject.inspect} to be a kind of #{@klass.name}, not #{@subject.class.name}."
    end
  end

  matcher :eq do
    def initialize(expected)
      @expected = expected
    end

    def match?
      @subject == @expected
    end

    def failure_message
      "expected #{@expected.inspect}, got: #{@subject.inspect} (using ==)."
    end

    def negative_failure_message
      "expected #{@expected.inspect}, not to be: #{@subject.inspect} (using ==)."
    end
  end

  matcher :equal do
    def match expected, actual
      expected.equal? actual
    end

    def failure_message_for_should
      "expected #{actual.inspect} to be the same as #{expected.inspect}."
    end

    def failure_message_for_should_not
      "expected #{actual.inspect} to not be equal to #{expected.inspect}."
    end
  end

  matcher :raise_error do
    def initialize(klass)
      @klass = klass
    end

    def match?
      @klass ||= Exception
      passed = true

      begin
        @subject.call
        passed = false
      rescue => e
        @error = e
      end

      passed
    end

    def failure_message
      "expected #@klass to be raised, but nothing was."
    end

    def negative_failure_message
      "did not expect an error, but #{@error.class} was raised"
    end
  end

  matcher :be_empty do
    def match?
      @subject.empty?
    end

    def failure_message
      "expected #{@subject.inspect} to be empty"
    end
  end

  matcher :respond_to do
    def initialize(method_name)
      @method_name = method_name
    end

    def match?
      @subject.respond_to? @method_name
    end

    def failure_message
      "expected #{@subject.inspect} (#{@subject.class}) to respond to #{@method_name}."
    end
  end
end
