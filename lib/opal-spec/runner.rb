module Spec
  class Runner
    def self.in_browser?
      %x{
        if (typeof(window) !== 'undefined' && typeof(document) !== 'undefined') {
          return true;
        }

        return false;
      }
    end

    def self.in_phantom?
      %x{
        if (typeof(phantom) !== 'undefined' && phantom.exit) {
          return true;
        }

        return false;
      }
    end

    def self.autorun
      if in_browser?
        %x{
          setTimeout(function() {
            #{ Runner.new.run };
          }, 0);
        }
      end
    end

    def initialize
      if Runner.in_phantom?
        @formatter = PhantomFormatter.new
      elsif Runner.in_browser?
        @formatter = BrowserFormatter.new
      else
        @formatter = RSpecFormatter.new
      end
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