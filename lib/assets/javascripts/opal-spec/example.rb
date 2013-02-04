module OpalSpec
  class Example
    attr_reader :description, :example_group, :exception
    attr_accessor :asynchronous

    def initialize(group, desc, block)
      @example_group = group
      @description   = desc
      @__block__     = block
    end

    def finish_running
      if @exception
        @example_group.example_failed self
      else
        @example_group.example_passed self
      end
    end

    def run
      begin
        @example_group.example_started self
        run_before_hooks
        instance_eval(&@__block__)
      rescue => e
        @exception = e
      ensure
        run_after_hooks unless @asynchronous
      end

      if @asynchronous
        # must wait ...
      else
        finish_running
      end
    end

    def run_after_hooks
      begin
        @example_group.after_hooks.each do |after|
        instance_eval &after
        end
      rescue => e
        @exception = e
      end
    end

    def run_before_hooks
      @example_group.before_hooks.each do |before|
        instance_eval &before
      end
    end

    def run_async(&block)
      begin
        block.call
      rescue => e
        @exception = e
      ensure
        run_after_hooks
      end

      finish_running
    end

    def set_timeout(duration, &block)
      %x{
        setTimeout(function() {
          #{ block.call };
        }, duration);
      }

      self
    end
  end
end