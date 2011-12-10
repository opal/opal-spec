module OpalSpec
  class ExampleGroup
    @example_groups = []
    def self.example_groups
      @example_groups
    end

    def self.create desc, block
      @example_groups << self.new(desc, block)
    end

    def initialize desc, block
      @desc = desc
      @examples = []
      @before_hooks = []
      @after_hooks = []
      instance_eval &block
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
      @before_hooks
    end

    def after_hooks
      @after_hooks
    end

    def run runner
      runner.example_group_started self
      @examples.each { |example| example.run runner }
      runner.example_group_finished self
    end

    def description
      @desc
    end
  end
end
