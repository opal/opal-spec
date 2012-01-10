module OpalSpec
  class Formatter
    def initialize
      @examples        = []
      @failed_examples = []
    end

    def start
    end

    def finish
      @failed_examples.each_with_index do |example, i|
        exception = example.exception
        description = example.description
        group = example.example_group

        case exception
        when OpalSpec::ExpectationNotMetError
          puts "\n#{i + 1}) Failure:\n#{group.description} #{description}:"
          puts "#{exception.message}\n"
        else
          puts "\n#{i + 1}) Error:\n#{group.description} #{description}:"
          puts "#{exception.class}: #{exception.message}\n"
          puts "    #{exception.backtrace.join "\n    "}\n"
        end
      end

      puts "\n#{example_count} examples, #{@failed_examples.size} failures"
    end

    def example_group_started group
      @example_group = group
    end

    def example_group_finished group
    end

    def example_started example
      @examples << example
      @example = example
    end

    def example_passed example
    end

    def example_failed example
      @failed_examples << example
    end

    def example_count
      @examples.size
    end
  end
end
