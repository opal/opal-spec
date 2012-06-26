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
      raise "Not running in browser" unless Document.body_ready?

      @summary_element = DOM.parse '<p class="summary"></p>'
      @summary_element.append_to_body

      @groups_element = DOM.parse '<ul class="example_groups"></ul>'
      @groups_element.append_to_body

      DOM.parse("<style>#{ CSS }</style>").append_to_head
    end

    def finish
      text = "\n#{example_count} examples, #{@failed_examples.size} failures"
      @summary_element.html = text
    end

    def example_group_started group
      @example_group = group
      @example_group_failed = false

      @group_element = DOM.parse <<-HTML
        <li>
          <span class="group_description">
            #{ group.description }
          </span>
        </li>
      HTML

      @example_list = DOM.parse <<-HTML
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
        output  = "#{exception.class}: #{exception.message}\n"
        output += "    #{exception.backtrace.join "\n    "}\n"
      end

      wrapper = DOM.parse '<li class="example failed"></li>'

      description = DOM.parse <<-HTML
        <span class="example_description">#{ example.description }</span>
      HTML

      exception = DOM.parse <<-HTML
        <pre class="exception">#{ output }</pre>
      HTML

      wrapper << description
      wrapper << exception

      @example_list.append wrapper
      @example_list.css 'display', 'list-item'
    end

    def example_passed example
      out = DOM.parse <<-HTML
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