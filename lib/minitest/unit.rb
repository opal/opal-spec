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
    bt
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

    def options
      @options ||= {}
    end

    @@installed_at_exit ||= false
    @@out = $stdout

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

        at_exit { false if exit_code && exit_code != 0 }

        exit_code = MiniTest::Unit.new.run ARGV
      } unless @@installed_at_exit
      @@installed_at_exit = true
    end

    def self.output
      @@out
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

    ##
    # Return all plugins' run methods (methods that start with "run_").

    def self.plugins
      # FIXME:
      # @@plugins ||= (["run_tests"] +
                     # public_instance_methods(false).
                     # grep(/^run_/).map { |s| s.to_s }).uniq
      ["run_tests"]
    end

    def output
      self.class.output
    end

    def _run_anything type
      suites = TestCase.send "#{type}_suites"
      return if suites.empty?

      start = Time.now

      puts
      puts "# Running #{type}s:"
      puts

      # FIXME: mass-assignment
      # @test_count, @assertion_count = 0, 0
      @test_count = 0; @assertion_count = 0
      sync = output.respond_to? :"sync=" # stupid emacs

      # FIXME: mass-assignment
      # old_sync, output.sync = output.sync, true if sync
      if sync
        old_sync = output.sync
        output.sync = true
      end

      results = _run_suites suites, type

      # FIXME:
      # @test_count      = results.inject(0) { |sum, (tc, _)| sum + tc }
      @test_count      = results.inject(0) { |sum, tc| sum + tc[0] }
      # FIXME:
      # @assertion_count = results.inject(0) { |sum, (_, ac)| sum + ac }
      @assertion_count = results.inject(0) { |sum, ac| sum + ac[1] }

      output.sync = old_sync if sync

      t = Time.now - start

      puts
      puts
      puts "Finished #{type}s in %.6fs, %.4f tests/s, %.4f assertions/s." %
        [t, test_count / t, assertion_count / t]

      report.each_with_index do |msg, i|
        # FIXME:
        # puts "\n%3d) %s" % [i + 1, msg]
        puts "\n#{i + 1}) #{msg}"
      end

      puts

      status
    end

    def _run_suites suites, type
      suites.map { |suite| _run_suite suite, type }
    end

    def _run_suite suite, type
      header = "#{type}_suite_header"
      puts send(header, suite) if respond_to? header

      filter = options[:filter] || '/./'
      # FIXME:
      # filter = Regexp.new $1 if filter =~ /\/(.*)\//

      # FIXME:
      # assertions = suite.send("#{type}_methods").grep(filter).map { |method|
      assertions = suite.test_methods.map { |method|
        inst = suite.new method
        inst._assertions = 0

        print "#{suite}##{method} = " if @verbose

        @start_time = Time.now
        result = inst.run self
        time = Time.now - @start_time

        print "%.2f s = " % time if @verbose
        print result
        puts if @verbose

        inst._assertions
      }

      return assertions.size, assertions.inject(0) { |sum, n| sum + n }
    end

    def location e # :nodoc:
      last_before_assertion = ""
      e.backtrace.reverse_each do |s|
        break if s =~ /in .(assert|refute|flunk|pass|fail|raise|must|wont)/
        last_before_assertion = s
      end
      # last_before_assertion.sub(/:in .*$/, '')
      last_before_assertion
    end

    ##
    # Writes status for failed test +meth+ in +klass+ which finished with
    # exception +e+

    def puke klass, meth, e
      e = case e
          when MiniTest::Skip then
            @skips += 1
            return "S" unless @verbose
            "Skipped:\n#{meth}(#{klass}) [#{location e}]:\n#{e.message}\n"
          when MiniTest::Assertion then
            @failures += 1
            "Failure:\n#{meth}(#{klass}) [#{location e}]:\n#{e.message}\n"
          else
            @errors += 1
            bt = MiniTest::filter_backtrace(e.backtrace).join "\n    "
            "Error:\n#{meth}(#{klass}):\n#{e.class}: #{e.message}\n    #{bt}\n"
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
      # FIXME: remove this
      self.options = {}

      puts "Run options: #{help}"

      # FIXME: remove this
      @test_count = 0

      self.class.plugins.each do |plugin|
        send plugin
        # FIXME:
        # break unless report.empty?
      end

      return failures + errors if @test_count > 0 # or return nil
    end

    ##
    # Run test suites matching +filter+

    def run_tests
      _run_anything :test
    end

    def status io = self.output
      # FIXME:
      # format = "%d tests, %d assertions, %d failures, %d errors, %d skips"
      # io.puts format % [test_count, assertion_count, failures, errors, skips]
      t = test_count
      a = assertion_count
      f = failures
      e = errors
      s = skips

      puts "#{t} tests, #{a} assertions, #{f} failures, #{e} errors, #{s} skips"
    end

    ##
    # Subclass TestCase to create your own tests. Typically you'll want a
    # TestCase subclass per implementation class.
    #
    # See MiniTest::Assertions

    class TestCase
      attr_reader :__name__ # :nodoc:

      # FIXME:
      # PASSTHROUGH_EXCEPTIONS = [NoMemoryError, SignalException,
                                # Interrupt, SystemExit] # :nodoc:
      PASSTHROUGH_EXCEPTIONS = []

      # FIXME:
      # SUPPORTS_INFO_SIGNAL = Signal.list['INFO'] # :nodoc:
      SUPPORTS_INFO_SIGNAL = false

      ##
      # Runs the tests reporting the status to +runner+

      def run runner
        trap "INFO" do
          time = runner.start_time ? Time.now - runner.start_time : 0
          warn "%s#%s %.2fs" % [self.class, self.__name__, time]
          runner.status $stderr
        # FIXME:
        # end if SUPPORTS_INFO_SIGNAL
        end if false && SUPPORTS_INFO_SIGNAL

        result = ""
        begin
          @passed = nil
          self.setup
          self.run_setup_hooks
          self.__send__ self.__name__
          result = "." unless io?
          @passed = true
        # FIXME:
        # rescue *PASSTHROUGH_EXCEPTIONS
          # raise

        # FIXME:
        # rescue Exception => e
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

      def initialize name # :nodoc:
        @__name__ = name
        @__io__ = nil
        @passed = nil
      end

      def io
        @__io__ = true
        MiniTest::Unit.output
      end

      def io?
        @__io__
      end

      def self.reset # :nodoc:
        @@test_suites = {}
      end

      reset

      ##
      # Call this at the top of your tests when you absolutely
      # positively need to have your ordered tests. In doing so, you're
      # admitting that you suck and your tests are weak.

      def self.i_suck_and_my_tests_are_order_dependent!
        class << self
          define_method :test_order do :alpha; end
        end
      end

      def self.inherited klass # :nodoc:
        @@test_suites[klass] = true
        klass.reset_setup_teardown_hooks
        super
      end

      def self.test_order # :nodoc:
        :random
      end

      def self.test_suites # :nodoc:
        # FIXME:
        # @@test_suites.keys.sort_by { |ts| ts.name.to_s }
        @@test_suites.keys
      end

      def self.test_methods # :nodoc:
        methods = public_instance_methods(true).grep(/^test/).map { |m| m.to_s }

        case self.test_order
        when :random then
          max = methods.size
          # FIXME:
          # methods.sort_by { rand max }
        when :alpha, :sorted then
          methods.sort
        else
          raise "Unknown test_order: #{self.test_order.inspect}"
        end

        # FIXME: remove this line - use result of case statement
        methods
      end

      ##
      # Returns true if the test passed

      def passed?
        @passed
      end

      ##
      # Runs before every test. Use this to refactor test initialization.

      def setup; end

      ##
      # Runs after every test. Use this to refactor test cleanup.

      def teardown; end

      def self.reset_setup_teardown_hooks # :nodoc:
        @setup_hooks = []
        @teardown_hooks = []
      end

      reset_setup_teardown_hooks

      ##
      # Adds a block of code that will be executed before every TestCase is
      # run. Equivalent to +setup+, but usable multiple times and without
      # re-opening any classes.
      #
      # All of the setup hooks will run in order after the +setup+ method, if
      # one is defined.
      #
      # The argument can be any object that responds to #call or a block.
      # That means that this call,
      #
      #     MiniTest::TestCase.add_setup_hook { puts "foo" }
      #
      # ... is equivalent to:
      #
      #     module MyTestSetup
      #       def call
      #         puts "foo"
      #       end
      #     end
      #
      #     MiniTest::TestCase.add_setup_hook MyTestSetup
      #
      # The blocks passed to +add_setup_hook+ take an optional parameter that
      # will be the TestCase instance that is executing the block.

      def self.add_setup_hook arg=nil, &block
        hook = arg || block
        @setup_hooks << hook
      end

      def self.setup_hooks # :nodoc:
        if superclass.respond_to? :setup_hooks then
          superclass.setup_hooks
        else
          []
        end + @setup_hooks
      end

      def run_setup_hooks # :nodoc:
        self.class.setup_hooks.each do |hook|
          if hook.respond_to?(:arity) && hook.arity == 1
            hook.call(self)
          else
            hook.call
          end
        end
      end

      ##
      # Adds a block of code that will be executed after every TestCase is
      # run. Equivalent to +teardown+, but usable multiple times and without
      # re-opening any classes.
      #
      # All of the teardown hooks will run in reverse order after the
      # +teardown+ method, if one is defined.
      #
      # The argument can be any object that responds to #call or a block.
      # That means that this call:
      #
      #     MiniTest::TestCase.add_teardown_hook { puts "foo" }
      #
      # ... is equivalent to:
      #
      #     module MyTestTeardown
      #       def call
      #         puts "foo"
      #       end
      #     end
      #
      #     MiniTest::TestCase.add_teardown_hook MyTestTeardown
      #
      # The blocks passed to +add_teardown_hook+ take an optional parameter
      # that will be the TestCase instance that is executing the block.

      def self.add_teardown_hook arg=nil, &block
        hook = arg || block
        @teardown_hooks << hook
      end

      def self.teardown_hooks # :nodoc:
        if superclass.respond_to? :teardown_hooks then
          superclass.teardown_hooks
        else
          []
        end + @teardown_hooks
      end

      def run_teardown_hooks # :nodoc:
        self.class.teardown_hooks.reverse_each do |hook|
          if hook.respond_to?(:arity) && hook.arity == 1
            hook.call(self)
          else
            hook.call
          end
        end
      end

      include MiniTest::Assertions
    end # class TestCase
  end # class Unit
end # module MiniTest

if $DEBUG then
  module Test                # :nodoc:
    module Unit              # :nodoc:
      class TestCase         # :nodoc:
        def self.inherited x # :nodoc:
          # this helps me ferret out porting issues
          raise "Using minitest and test/unit in the same process #{x}"
        end
      end
    end
  end
end

