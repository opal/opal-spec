module Kernel
  def describe desc, &block
    OSpec::ExampleGroup.create desc, block
  end

  def mock obj
    Object.new
  end
end