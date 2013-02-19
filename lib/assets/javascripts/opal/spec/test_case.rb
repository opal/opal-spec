module OpalTest
  class TestCase

    def self.test_cases
      @test_cases ||= []
    end

    def self.inherited(klass)
      TestCase.test_cases << klass
      klass.instance_eval { @setup_hooks = []; @teardown_hooks = [] }
    end

    def self.description
      to_s
    end

    def self.run(runner)
      @runner = runner
      @runner.example_group_started self

      @running_examples = self.instance_methods.grep(/^test_/)
      run_next_example
    end

    def self.run_next_example
      if @running_examples.empty?
        @runner.example_group_finished self
      else
        self.new(@running_examples.shift).run(@runner)
      end
    end

    def self.example_started(example)
      @runner.example_started(example)
    end

    def self.example_passed(example)
      @runner.example_passed(example)
      run_next_example
    end

    def self.example_failed(example)
      @runner.example_failed(example)
      run_next_example
    end

    def self.setup_hooks
      @parent ? [].concat(@parent.setup_hooks).concat(setup_hooks) : @setup_hooks
    end

    def self.teardown_hooks
      @parent ? [].concat(@parent.teardown_hooks).concat(@teardown_hooks) : @teardown_hooks
    end

    def initialize(name)
      @__name__ = name
      @example_group = self.class
      @description = name.sub(/^test_(\d)+_/, '')
    end

    def description
      @__name__
    end

    attr_reader :example_group, :exception

    def finish_running
      if @exception
        @example_group.example_failed self
      else
        @example_group.example_passed self
      end
    end

    def run(runner)
      @runner = runner
      begin
        @example_group.example_started self
        run_before_hooks
        setup
        __send__ @__name__
      rescue => e
        @exception = e
      ensure
        unless @asynchronous
          teardown
          run_after_hooks
        end
      end

      if @asynchronous
        # must wait ...
      else
        finish_running
      end
    end

    def run_after_hooks
      begin
        @example_group.teardown_hooks.each do |after|
        instance_eval &after
        end
      rescue => e
        @exception = e
      end
    end

    def run_before_hooks
      @example_group.setup_hooks.each do |before|
        instance_eval &before
      end
    end

    def setup
    end

    def teardown
    end
  end
end
