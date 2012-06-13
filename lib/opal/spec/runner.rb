module Spec
  class Runner
    def initialize
      @formatter = BrowserFormatter.new
    end

    def run
      groups = ExampleGroup.example_groups
      @formatter.start
      groups.each { |group| group.run self }
      @formatter.finish
    end

    def example_group_started group
      @formatter.example_group_started group
    end

    def example_group_finished group
      @formatter.example_group_finished group
    end

    def example_started example
      @formatter.example_started example
    end

    def example_passed example
      @formatter.example_passed example
    end

    def example_failed example
      @formatter.example_failed example
    end
  end
end