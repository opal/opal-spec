module Kernel
  def describe desc, &block
    OpalSpec::ExampleGroup.create desc, block
  end

  def mock obj
    Object.new
  end
end