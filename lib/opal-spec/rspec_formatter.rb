module Spec
  class RSpecFormatter
    def initialize
      @examples        = []
      @failed_examples = []

      @spec_collector = `spec_collector`
    end

    def start
    end

    def finish
    end

    def example_group_started group
      @example_group = group
      @example_group_failed = false

      `#{@spec_collector}.example_group_started(#{group.description})`
    end

    def example_group_finished group
      `#{@spec_collector}.example_group_finished(#{@example_group.description})`
    end

    def example_started example
      @examples << example
      @example = example
    end

    def example_failed example
      @failed_examples << example
      @example_group_failed = true
      `#{@spec_collector}.example_failed(#{example.description}, #{example.exception.message})`
    end

    def example_passed example
      `#{@spec_collector}.example_passed(#{example.description})`
    end

    def example_count
      @examples.size
    end
  end
end