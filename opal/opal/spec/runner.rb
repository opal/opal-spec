module OpalSpec
  class Runner
    def self.in_browser?
      `typeof(document) !== 'undefined'`
    end

    def self.in_phantom?
      `typeof(phantom) !== 'undefined' || typeof(OPAL_SPEC_PHANTOM) !== 'undefined'`
    end

    def self.autorun
      if in_browser?
        `setTimeout(function() { #{ Runner.new.run } }, 0)`
      else
        Runner.new.run
      end
    end

    def initialize
      if Runner.in_phantom?
        @formatter = PhantomFormatter.new
      elsif Runner.in_browser?
        @formatter = BrowserFormatter.new
      end
    end

    def run
      @groups = Example.groups.dup
      @formatter.start
      run_next_group
    end

    def run_next_group
      if @groups.empty?
        @formatter.finish
      else
        @groups.shift.run self
      end
    end

    def example_group_started group
      @formatter.example_group_started group
    end

    def example_group_finished group
      @formatter.example_group_finished group
      run_next_group
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
