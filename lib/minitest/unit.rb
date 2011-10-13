module MiniTest

  class Assertion < Exception; end

  class Skip < Assertion; end

  module Assertions

    def _assertions=(n)
      @_assertions = n
      n
    end

    def _assertions
      @_assertions ||= 0
    end

    def assert(test, msg = nil)
      msg ||= "Failed assertion, no message given."
      self._assertions += 1
      unless test
        msg = msg.call if Proc === msg
        raise MiniTest::Assertion, msg
      end
    end

    def assert_equal(exp, act, msg = nil)
      msg ||= proc { "Expected: #{exp.inspect}, Actual: #{act.inspect}" }
      assert(exp == act, msg)
    end
  end

  class Unit

    attr_accessor :report, :failures, :errors, :skips
    attr_accessor :test_count, :assertion_count
    attr_accessor :start_time
    attr_accessor :help
    attr_accessor :verbose
    attr_writer   :options

    def self.autorun
      at_exit do
        MiniTest::Unit.new.run ARGV
      end
    end

    def run(args = [])
      suites = TestCase.test_suites

      @test_count = 0
      @assertion_count = 0

      results = run_suites suites

      @test_count      = results.inject(0) { |sum, tc| sum + tc[0] }
      @assertion_count = results.inject(0) { |sum, ac| sum + ac[1] }

      @report.each_with_index do |msg, i|
        puts "\n#{i + 1}) #{msg}"
      end

      puts ""
      status
    end

    def run_suites(suites)
      suites.map { |suite| run_suite suite }
    end

    def run_suite(suite)
      assertions = suite.test_methods.map do |method|
        inst = suite.new method
        inst._assertions = 0
        result = inst.run self

        puts result

        inst._assertions
      end

      return assertions.size, assertions.inject(0) { |sum, n| sum + n }
    end

    def puke(klass, meth, e)
      e = case e
          when MiniTest::Skip
            @skips += 1
            return "S"
          when MiniTest::Assertion
            @failures += 1
            "Failure:\n#{meth}(#{klass}):\n#{e.message}\n"
          else
            @errors += 1
            "Error:\n#{meth}(#{klass}):\n#{e.message}\n"
          end
      @report << e
      e[0, 1]
    end

    def initialize
      @report = []
      @errors = @failures = @skips = 0
      @verbose = false
    end

    def status
      t = test_count
      a = assertion_count
      f = failures
      e = errors
      s = skips

      puts "#{t} tests, #{a} assertions, #{f} failures, #{e} errors, #{s} skips"
    end

    class TestCase
      attr_reader :__name__

      def run(runner)
        result = ""
        begin
          @passed = nil
          self.setup
          self.run_setup_hooks
          self.__send__ self.__name__
          result = "." unless io?
          @passed = true
        rescue => e
          @passed = false
          result = runner.puke self.class, self.__name__, e
        ensure
          begin
            self.run_teardown_hooks
            self.teardown
          rescue => e
            result = runner.puke self.class, self.__name__, e
          end
        end
        result
      end

      def initialize(name)
        @__name__ = name
        @__io__ = nil
        @passed = nil
      end

      def io?
        @__io__
      end

      def self.reset
        @@test_suites = {}
      end

      reset

      def self.inherited(klass)
        @@test_suites[klass] = true
        klass.reset_setup_teardown_hooks
        super
      end

      def self.test_suites
        @@test_suites.keys
      end

      def self.test_methods
        methods = public_instance_methods(true).grep(/^test/)
      end

      def setup; end

      def teardown; end

      def self.reset_setup_teardown_hooks
        @setup_hooks = []
        @teardown_hooks = []
      end

      reset_setup_teardown_hooks

      def run_setup_hooks
        # FIXME
      end

      def run_teardown_hooks
        # FIXME
      end

      include MiniTest::Assertions

    end # TestCase
  end # Unit
end # MiniTest

