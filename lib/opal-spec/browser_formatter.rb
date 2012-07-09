module Spec
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
      @start_time = Time.now
      @summary_element = Element.new '<p class="summary"></p>'
      @summary_element.append_to_body

      @groups_element = Element.new '<ul class="example_groups"></ul>'
      @groups_element.append_to_body

      Element.new("<style>#{ CSS }</style>").append_to_head
    end

    def finish
      time = Time.now.to_i - @start_time.to_i
      text = "\n#{example_count} examples, #{@failed_examples.size} failures (time taken: #{time})"
      @summary_element.html = text
    end

    def example_group_started group
      @example_group = group
      @example_group_failed = false

      @group_element = Element.new <<-HTML
        <li>
          <span class="group_description">
            #{ group.description }
          </span>
        </li>
      HTML

      @example_list = Element.new <<-HTML
        <ul class="examples"></ul>
      HTML

      @group_element << @example_list
      @groups_element << @group_element
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
      when Spec::ExpectationNotMetError
        output  = exception.message
      else
        output  = "#{exception.class.name}: #{exception.message}\n"
        output += "    #{exception.backtrace.join "\n    "}\n"
      end

      wrapper = Element.new('<li class="example failed"></li>')

      description = Element.new('<span class="example_description"></span>')
      description.text = example.description

      exception = Element.new('<pre class="exception"></pre>')
      exception.text = output

      wrapper << description
      wrapper << exception

      @example_list.append wrapper
      @example_list.css 'display', 'list-item'
    end

    def example_passed example
      out = Element.new <<-HTML
        <li class="example passed">
          <span class="example_description">#{ example.description }</span>
        </li>
      HTML

      @example_list.append out
    end

    def example_count
      @examples.size
    end
  end
end