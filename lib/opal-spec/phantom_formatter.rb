module Spec
  class RSpecFormatter
    def initialize
      @examples        = []
      @failed_examples = []
    end

    def start
    end

    def finish
      `phantom.exit()`
    end

    def example_group_started group
      @example_group = group
      @example_group_failed = false
      `console.log(#{group.description})`
    end

    def example_group_finished group
    end

    def example_started example
      @examples << example
      @example = example
    end

    def example_failed example
      @failed_examples << example
      @example_group_failed = true
      `console.log("  failed: " + #{example.exception.message})`
    end

    def example_passed example
      `console.log("  passed: " + #{example.description})`
    end

    def example_count
      @examples.size
    end
  end
end