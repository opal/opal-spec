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

      @before_hooks = []
      @after_hooks  = []
    end

    def it desc, &block
      @examples << Example.new(self, desc, block)
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

    def run runner
      runner.example_group_started self
      @examples.each { |example| example.run runner }
      runner.example_group_finished self
    end

    def description
      @parent ? "#{@parent.description} #{@desc}" : @desc
    end
  end
end
