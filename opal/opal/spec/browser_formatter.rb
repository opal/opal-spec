module OpalSpec
  class BrowserFormatter
    CSS = <<-CSS

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
    CSS

    class Node

      attr_reader :element

      def self.create(tag)
        new(`document.createElement(tag)`)
      end

      def initialize(element)
        @element = element
      end

      def class_name=(name)
        `#{ @element }.className = name`
      end

      def html=(html)
        `#{ @element }.innerHTML = html`
      end

      def text=(text)
        self.html = text.gsub(/</, '&lt').gsub(/>/, '&gt')
      end

      def type=(type)
        `#{ @element }.type = type`
      end

      def append(child)
        `#{ @element }.appendChild(#{ child.element })`
      end

      def css_text=(text)
        %x{
          if (#{ @element }.styleSheet) {
            #{ @element }.styleSheet.cssText = text;
          }
          else {
            #{ @element }.appendChild(document.createTextNode(text));
          }
        }
      end

      def style(name, value)
        `#{@element}.style[name] = value`
      end

      def append_to_head
        `document.getElementsByTagName('head')[0].appendChild(#{@element})`
      end
    end

    def initialize
      @examples        = []
      @failed_examples = []
    end

    def start
      raise "Not running in browser" unless Runner.in_browser?

      @summary_element = Node.create 'p'
      @summary_element.class_name = "summary"
      @summary_element.text = "Runner..."

      @groups_element = Node.create("ul")
      @groups_element.class_name = "example_groups"

      target = Node.new(`document.body`)
      target.append @summary_element
      target.append @groups_element

      styles = Node.create "style"
      styles.type = "text/css"
      styles.css_text = CSS
      styles.append_to_head

      @start_time = Time.now.to_f
    end

    def finish
      time = Time.now.to_f - @start_time
      text = "\n#{example_count} examples, #{@failed_examples.size} failures (time taken: #{time})"

      @summary_element.text = text
    end

    def example_group_started group
      @example_group = group
      @example_group_failed = false

      @group_element = Node.create("li")

      description = Node.create("span")
      description.class_name = "group_description"
      description.text = group.description.to_s
      @group_element.append description

      @example_list = Node.create "ul"
      @example_list.class_name = "examples"
      @group_element.append @example_list

      @groups_element.append @group_element
    end

    def example_group_finished group
      if @example_group_failed
        @group_element.class_name = "group failed"
      else
        @group_element.class_name = "group passed"
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
        output  = "#{exception.class.name}: #{exception.message}\n"
        output += "    #{exception.backtrace.join "\n    "}\n"
      end

      wrapper = Node.create "li"
      wrapper.class_name = "example failed"

      description = Node.create "span"
      description.class_name = "example_description"
      description.text = example.description.to_s

      exception = Node.create "pre"
      exception.class_name = "exception"
      exception.text = output

      wrapper.append description
      wrapper.append exception

      @example_list.append wrapper
      @example_list.style :display, "list-item"
    end

    def example_passed example
      wrapper = Node.create "li"
      wrapper.class_name = "example passed"

      description = Node.create "span"
      description.class_name = "example_description"
      description.text = example.description.to_s

      wrapper.append description
      @example_list.append wrapper
    end

    def example_count
      @examples.size
    end
  end
end
