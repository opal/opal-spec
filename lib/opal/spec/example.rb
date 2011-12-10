module OpalSpec
  class Example
    attr_reader :description, :example_group, :exception

    def initialize(group, desc, block)
      @example_group = group
      @description   = desc
      @__block__     = block
    end

    def run_before_hooks
      @example_group.before_hooks.each do |before|
        instance_eval &before 
      end
    end

    def run_after_hooks
      @example_group.after_hooks.each do |after|
        instance_eval &after
      end
    end

    def run runner
      begin
        runner.example_started self
        run_before_hooks
        instance_eval &@__block__
      rescue => e
        @exception = e
      ensure
        begin
          run_after_hooks
        rescue => e
          @exception = e
        end
      end

      if @exception
        runner.example_failed self
      else
        runner.example_passed self
      end
    end
  end
end
