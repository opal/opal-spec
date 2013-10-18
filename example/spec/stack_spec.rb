require 'spec_helper'

describe Stack do
  before do
    @stack = Stack.new
  end

  it "should be initially empty" do
    @stack.empty?.should be_true
  end

  it "can contain an object" do
    @stack.push(1)
    @stack.pop.should == 1
  end
end

