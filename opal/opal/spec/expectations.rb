module OpalSpec
  class ExpectationNotMetError < StandardError; end

  module Expectations; end

  def self.matcher name, &block
    klass = Class.new(Matcher, &block)

    klass.define_method(:matcher_name) do
      name
    end

    Expectations.define_method(name) do |*args|
      klass.new(*args)
    end
  end

  matcher :be_nil do
    def match expected, actual
      actual.nil?
    end

    def failure_message_for_should
      "expected #{expected.inspect} to be nil."
    end
  end

  matcher :be_true do
    def match expected, actual
      actual == true
    end

    def failure_message_for_should
      "expected #{actual.inspect} to be true."
    end
  end

  matcher :be_false do
    def match expected, actual
      actual == false
    end

    def failure_message_for_should
      "expected #{actual.inspect} to be false."
    end
  end

  matcher :be_kind_of do
    def match expected, actual
      actual.kind_of? expected
    end

    def failure_message_for_should
      "expected #{actual.inspect} to be a kind of #{expected.name}, not #{actual.class.name}."
    end
  end

  matcher :eq do
    def match expected, actual
      expected == actual
    end

    def failure_message_for_should
      "expected #{expected.inspect}, got: #{actual.inspect} (using ==)."
    end

    def failure_message_for_should_not
      "expected #{expected.inspect}, not to be: #{actual.inspect} (using ==)."
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
    def initialize(&block)
      @block = block
    end

    def match expected, actual
      ok = true

      begin
        @block.call
        ok = false
      rescue => e
        @error = e
      end

      ok
    end

    def failure_message_for_should
      "expected #{actual} to be raised, but nothing was."
    end
  end

  matcher :be_empty do
    def match expected, actual
      actual.empty?
    end

    def failure_message_for_should
      "expected #{actual.inspect} to be empty"
    end
  end

  matcher :respond_to do
    def match expected, actual
      actual.respond_to? expected
    end

    def failure_message_for_should
      "expected #{actual.inspect} (#{actual.class}) to respond to #{expected}."
    end
  end
end
