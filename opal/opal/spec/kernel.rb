module Kernel
  def describe(desc, &block)
    group = OpalTest::Spec.create(desc, block)

    stack = OpalTest::Spec.stack
    stack << group
    group.class_eval &block
    stack.pop
  end

  def mock(obj)
    Object.new
  end
end
