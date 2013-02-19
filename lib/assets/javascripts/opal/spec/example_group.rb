module Spec
  class ExampleGroup
    @example_groups = []
    def self.example_groups
      @example_groups
    end

    @stack = []
    def self.create desc, block
      group = self.new desc, @stack.last
      @example_groups << group

      @stack << group
      group.instance_eval &block
      @stack.pop
    end

    def initialize desc, parent
      @desc     = desc.to_s
      @parent   = parent
      @examples = []

      @base_class = Class.new(Example)

      @before_hooks = []
      @after_hooks  = []
    end

    def it(desc, &block)
      @examples << @base_class.new(self, desc, block)
    end

    def let(name, &block)
      @base_class.define_method(name) do
        @_memoized ||= {}
        @_memoized.fetch(name) { |n| @_memoized[n] = instance_eval(&block) }
      end
    end

    def async(desc, &block)
      example = Example.new(self, desc, block)
      example.asynchronous = true
      @examples << example
    end

    def it_behaves_like(*objs)
    end

    def before type = :each, &block
      raise "unsupported before type: #{type}" unless type == :each
      @before_hooks << block
    end

    def after type = :each, &block
      raise "unsupported after type: #{type}" unless type == :each
      @after_hooks << block
    end

    def before_hooks
      @parent ? [].concat(@parent.before_hooks).concat(@before_hooks) : @before_hooks
    end

    def after_hooks
      @parent ? [].concat(@parent.after_hooks).concat(@after_hooks) : @after_hooks
    end

    def run(runner)
      @runner = runner
      @runner.example_group_started self

      @running_examples = @examples.dup
      run_next_example
    end

    def run_next_example
      if @running_examples.empty?
        @runner.example_group_finished self
      else
        @running_examples.shift.run
      end
    end

    def example_started(example)
      @runner.example_started(example)
    end

    def example_passed(example)
      @runner.example_passed(example)
      run_next_example
    end

    def example_failed(example)
      @runner.example_failed(example)
      run_next_example
    end

    def description
      @parent ? "#{@parent.description} #{@desc}" : @desc
    end
  end
end
