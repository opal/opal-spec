module Kernel
  def describe(desc, &block)
    group = OpalSpec::Example.create(desc, block)

    stack = OpalSpec::Example.stack
    stack << group
    group.class_eval(&block)
    stack.pop
  end
end
