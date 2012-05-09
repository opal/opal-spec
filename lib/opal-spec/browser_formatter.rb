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
      }

      @summary_element = Element.new 'p'
      @summary_element.class_name = 'summary'
      @summary_element.append_to_body

      @groups_element = Element.new 'ul'
      @groups_element.class_name = 'example_groups'
      @groups_element.append_to_body

      styles = Element.new 'style'
      styles.html = CSS
      styles.append_to_head
    end

    def finish
      text = "\n#{example_count} examples, #{@failed_examples.size} failures"
      @summary_element.html = text
    end

    def example_group_started group
      @example_group = group
      @example_group_failed = false

      @group_element = Element.new 'li'

      description            = Element.new 'span'
      description.class_name = 'group_description'
      description.html       = group.description

      @group_element.append description

      @example_list            = Element.new 'ul'
      @example_list.class_name = 'examples'
      @example_list.hide

      @group_element.append @example_list
      @groups_element.append @group_element
    end

    def example_group_finished group
      if @example_group_failed
        @group_element.class_name = 'group failed'
      else
        @group_element.class_name = 'group passed'
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

      wrapper = Element.new 'li'
      wrapper.class_name = 'example failed'

      description = Element.new 'span'
      description.class_name = 'example_description'
      description.html       = example.description

      exception = Element.new 'pre'
      exception.class_name = 'exception'
      exception.html       = output

      wrapper.append description
      wrapper.append exception

      @example_list.append wrapper
      @example_list.style 'display', 'list-item'
    end

    def example_passed example
      wrapper = Element.new 'li'
      wrapper.class_name = 'example passed'

      description = Element.new 'span'
      description.class_name = 'example_description'
      description.html       = example.description

      wrapper.append description
      @example_list.append wrapper
    end

    def example_count
      @examples.size
    end
  end
end