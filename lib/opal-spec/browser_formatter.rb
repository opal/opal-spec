#require 'opal/spec/formatter'

module OpalSpec
  class BrowserFormatter
    CSS = <<-EOS

      body {
        font-size: 14px;
        font-family: Helvetica Neue, Helvetica, Arial, sans-serif;
      }

      pre {
        font-family: "Bitstream Vera Sans Mono", Monaco, "Lucida Console", monospace;
        font-size: 12px;
        color: #444444;
        white-space: pre;
        padding: 3px 0px 3px 12px;
        margin: 0px 0px 8px;

        background: #FAFAFA;
        -webkit-box-shadow: rgba(0,0,0,0.07) 0 1px 2px inset;
        -webkit-border-radius: 3px;
        -moz-border-radius: 3px;
        border-radius: 3px;
        border: 1px solid #DDDDDD;
      }

      ul.example_groups {
        list-style-type: none;
      }

      li.group.passed .group_description {
        color: #597800;
        font-weight: bold;
      }

      li.group.failed .group_description {
        color: #FF000E;
        font-weight: bold;
      }

      li.example.passed {
        color: #597800;
      }

      li.example.failed {
        color: #FF000E;
      }

      .examples {
        list-style-type: none;
      }
    EOS

    def initialize
      @examples        = []
      @failed_examples = []
    end

    def start
      %x{
        if (!document || !document.body) {
          #{ raise "Not running in browser." };
        }

        var groups_element = document.createElement('ul');
        groups_element.className = 'example_groups';
        document.body.appendChild(groups_element);

        var styles = document.createElement('style');
        styles.innerHTML = #{ CSS };
        document.head.appendChild(styles);
      }
      @groups_element = `groups_element`
    end

    def finish
      # @failed_examples.each_with_index do |example, i|
      #   exception = example.exception
      #   description = example.description
      #   group = example.example_group

      #   case exception
      #   when OpalSpec::ExpectationNotMetError
      #     puts "\n#{i + 1}) Failure:\n#{group.description} #{description}:"
      #     puts "#{exception.message}\n"
      #   else
      #     puts "\n#{i + 1}) Error:\n#{group.description} #{description}:"
      #     puts "#{exception.class}: #{exception.message}\n"
      #     puts "    #{exception.backtrace.join "\n    "}\n"
      #   end
      # end

      # puts "\n#{example_count} examples, #{@failed_examples.size} failures"
    end

    def example_group_started group
      @example_group = group
      @example_group_failed = false

      %x{
        var group_element = document.createElement('li');

        var description = document.createElement('span');
        description.className = 'group_description';
        description.innerHTML = #{group.description};
        group_element.appendChild(description);

        var example_list = document.createElement('ul');
        example_list.className = 'examples';
        example_list.style.display = 'none';
        group_element.appendChild(example_list);

        #@groups_element.appendChild(group_element);
      }

      @group_element = `group_element`
      @example_list  = `example_list`
    end

    def example_group_finished group
      if @example_group_failed
        `#@group_element.className = 'group failed';`
      else
        `#@group_element.className = 'group passed';`
      end
    end

    def example_started example
      @examples << example
      @example = example
    end

    def example_failed example
      @failed_examples << example
      @example_group_failed = true

      exception = example.exception

      case exception
      when OpalSpec::ExpectationNotMetError
        output  = exception.message
      else
        output  = "#{exception.class}: #{exception.message}\n"
        output += "    #{exception.backtrace.join "\n    "}\n"
      end

      %x{
        var wrapper = document.createElement('li');
        wrapper.className = 'example failed';

        var description = document.createElement('span');
        description.className = 'example_description';
        description.innerHTML = #{example.description};

        var exception = document.createElement('pre');
        exception.className = 'exception';
        exception.innerHTML = output;

        wrapper.appendChild(description);
        wrapper.appendChild(exception);

        #@example_list.appendChild(wrapper);
        #@example_list.style.display = 'list-item';
      }
    end

    def example_passed example
      %x{
        var wrapper = document.createElement('li');
        wrapper.className = 'example passed';

        var description = document.createElement('span');
        description.className = 'example_description';
        description.innerHTML = #{example.description};

        wrapper.appendChild(description);
        #@example_list.appendChild(wrapper);
      }
    end

    def example_count
      @examples.size
    end
  end
end