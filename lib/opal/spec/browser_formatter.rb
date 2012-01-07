require 'opal/spec/formatter'

module OpalSpec
  class BrowserFormatter < Formatter
    CSS = <<-EOS
      li.group.passed .group_description {
      }

      li.group.failed .group_description {
        color: red;
      }

      li.example.passed {
        color: green;
      }

      li.example.failed {
        color: red;
      }

      .examples {
        list-style-type: none;
      }
    EOS

    def start
      %x{
        if (!document || !document.body) {
          #{ raise "Not running in browser." };
        }

        var groups_element = document.createElement('ol');
        groups_element.className = 'example_groups';
        document.body.appendChild(groups_element);

        var styles = document.createElement('style');
        styles.innerHTML = #{ CSS };
        document.head.appendChild(styles);
      }
      @groups_element = `groups_element`
    end

    def finish
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
  end
end
