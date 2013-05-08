module Kernel
  def describe desc, &block
    OpalSpec::Example.create desc, block
  end
end
