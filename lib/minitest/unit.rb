require 'optparse'
require 'rbconfig'

##
# Minimal (mostly drop-in) replacement for test-unit.
#
# :include: README.txt

module MiniTest

  ##
  # Assertion base class

  class Assertion < Exception; end

  ##
  # Assertion raised when skipping a test

  class Skip < Assertion; end

  file = if RUBY_VERSION =~ /^1\.9/ then  # bt's expanded, but __FILE__ isn't :(
           File.expand_path __FILE__
          elsif __FILE__ =~ /^[^\.]/ then # assume both relative
            require 'pathname'
            pwd = Pathname.new Dir.pwd
            pn = Pathname.new File.expand_path(__FILE__)
            relpath = pn.relative_path_from(pwd) rescue pn
            pn = File.join ".", relpath unless pn.relative?
            pn.to_s
          else                            # assume both are expanded
            __FILE__
          end

  # './lib' in project dir, or '/usr/local/blahblah' if installed
  MINI_DIR = File.dirname(File.dirname(file)) # :nodoc:

  def self.filter_backtrace bt # :nodoc:
    return ["No backtrace"] unless bt

    new_bt = []
  end

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
      unless test then
        msg = msg.call if Proc === msg
        raise MiniTest::Assertion, msg
      end
      true
    end

    def assert_equal(exp, act, msg = nil)
      msg = message(msg, "") {
        "Expected #{exp.inspect}, Actual: #{act.inspect}"
      }
      assert(exp == act, msg)
    end

    def assert_instance_of(cls, obj, msg = nil)
      msg = message(msg) {
        "Expected #{obj.inspect} to be an instance of #{cls}, not #{obj.class}"
      }

      assert obj.instance_of?(cls), msg
    end

    def assert_kind_of(cls, obj, msg = nil)
      msg = message(msg) {
        "Expected #{obj.inspect} to be a kind of #{cls}, not #{obj.class}"
      }

      assert obj.kind_of?(cls), msg
    end

    def assert_nil(obj, msg = nil)
      msg = message(msg) { "Expected #{obj.inspect} to be nil" }
      assert obj.nil?, msg
    end

    def message(msg = nil, ending = ".", &default_)
      proc {
        custom_message = "#{msg}.\n" unless msg.nil? or msg.to_s.empty?
        "#{custom_message}#{default_.call}#{ending}"
      }
    end

    def refute(test, msg = nil)
      msg ||= "Failed refutation, no message given"
      not assert(! test, msg)
    end
  end

  class Unit

    attr_accessor :report, :failures, :errors, :skips
    attr_accessor :test_count, :assertion_count
    attr_accessor :start_time
    attr_accessor :help
    attr_accessor :verbose
    attr_writer   :options

    @@installed_at_exit ||= false

    ##
    # Registers MiniTest::Unit to run tests at process exit

    def self.autorun
      at_exit {
        next if $! # don't run if there was an exception

        # The order here is important. The at_exit handler must be
        # installed before anyone else gets a chance to install their
        # own, that way we can be assured that our exit will be last
        # to run (at_exit stacks).
        exit_code = nil

        at_exit { exit false if exit_code && exit_code != 0 }

        exit_code = MiniTest::Unit.new.run ARGV
      } unless @@installed_at_exit
      @@installed_at_exit = true
    end

    ##
    # Tells MiniTest::Unit to delegate to +runner+, an instance of a
    # MiniTest::Unit subclass, when MiniTest::Unit#run is called.

    def self.runner= runner
      @@runner = runner
    end

    ##
    # Returns the MiniTest::Unit subclass instance that will be used
    # to run the tests. A MiniTest::Unit instance is the default

    def self.runner
      @@runner ||= self.new
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

    def initialize # :nodoc:
      @report = []
      @errors = @failures = @skips = 0
      @verbose = false
    end

    def process_args args = []
      args
    end

    ##
    # Begins the full test run. Delagates to +runner+'s run method.

    def run args = []
      self.class.runner._run(args)
    end

    ##
    # Top level driver, controls all output and filtering.

    def _run args = []
      self.options = process_args args
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

