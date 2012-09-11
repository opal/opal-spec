module OSpec
  class PhantomFormatter
    def initialize
      @examples        = []
      @failed_examples = []
    end

    def log_green(str)
      `console.log('\\033[92m' + str + '\\033[0m')`
    end

    def log_red(str)
      `console.log('\\033[31m' + str + '\\033[0m')`
    end

    def log(str)
      `console.log(str)`
    end

    def start
    end

    def finish
      if @failed_examples.empty?
        log "\nFinished"
        log_green "#{example_count} examples, 0 failures"
        `phantom.exit(0)`
      else
        log "\nFailures:"
        @failed_examples.each_with_index do |example, idx|
          log "\n  #{idx+1}. #{example.example_group.description} #{example.description}"

          exception = example.exception
          case exception
          when OSpec::ExpectationNotMetError
            output  = exception.message
          else
            output  = "#{exception.class}: #{exception.message}\n"
            output += "      #{exception.backtrace.join "\n      "}\n"
          end
          log_red "    #{output}"
        end

        log "\nFinished"
        log_red "#{example_count} examples, #{@failed_examples.size} failures"
        `phantom.exit(1)`
      end
    end

    def example_group_started group
      @example_group = group
      @example_group_failed = false
      log "\n#{group.description}"
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
      log_red "  #{example.description}"
    end

    def example_passed example
      log_green "  #{example.description}"
    end

    def example_count
      @examples.size
    end
  end
end