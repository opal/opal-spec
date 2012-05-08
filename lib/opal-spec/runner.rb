# cheat until proper method available..
%x{
  setTimeout(function() {
  #{OpalSpec::Runner.new.run}
  }, 0);
}

module OpalSpec
  class Runner
    # def self.autorun
    #   at_exit { OpalSpec::Runner.new.run } 
    # end

    def initialize
      @formatters = [BrowserFormatter.new]
    end

    def run
      groups = ExampleGroup.example_groups
      @formatters.each { |f| f.start }
      groups.each { |group| group.run self }
      @formatters.each { |f| f.finish }
    end

    def example_group_started group
      @formatters.each { |f| f.example_group_started group }
    end

    def example_group_finished group
      @formatters.each { |f| f.example_group_finished group }
    end

    def example_started example
      @formatters.each { |f| f.example_started example }
    end

    def example_passed example
      @formatters.each { |f| f.example_passed example }
    end

    def example_failed example
      @formatters.each { |f| f.example_failed example }
    end
  end
end
