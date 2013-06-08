module OpalSpec
  class Runner
    def self.in_browser?
      $global[:document]
    end

    def self.in_phantom?
      $global[:phantom] or $global[:OPAL_SPEC_PHANTOM]
    end

    def self.autorun
      if in_browser?
        $global.setTimeout -> { Runner.new.run }, 0
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
