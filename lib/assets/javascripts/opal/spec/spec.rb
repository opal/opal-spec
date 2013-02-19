module OpalTest
  class Spec < TestCase

    def self.stack
      @stack ||= []
    end

    def self.create(desc, block)
      parent = Spec.stack.last

      Class.new(parent || Spec) do
        @desc   = desc
        @parent = parent
      end
    end

    def self.to_s
      "<OpalTest::Spec #{@desc.inspect}>"
    end

    def self.description
      @parent ? "#{@parent.description} #{@desc}" : @desc
    end

    def self.it(desc, &block)
      @specs ||= 0
      define_method("test_#{@specs += 1}_#{desc}", &block)
    end

    def self.async(desc, &block)
      self.it desc do
        self.async!
        instance_eval(&block)
      end
    end

    def self.let(name, &block)
      define_method(name) do
        @_memoized ||= {}
        @_memoized.fetch(name) { |n| @_memoized[n] = instance_eval(&block) }
      end
    end

    def self.subject(&block)
      let(:subject, &block)
    end

    def self.it_behaves_like(*objs)
    end

    # type is ignored (is always :each)
    def self.before(type = nil, &block)
      @setup_hooks << block
    end

    # type is ignored (is always :each)
    def self.after(type = nil, &block)
      @teardown_hooks << block
    end

    def description
      @description
    end

    def async!
      @asynchronous = true
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
      `setTimeout(#{block}, #{duration})`      
      self
    end
  end
end
