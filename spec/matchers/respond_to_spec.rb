class RespondToSpecs
  def foo; end
end

describe "respond_to" do
  it "should pass if the object responds to method" do
    RespondToSpecs.new.should respond_to(:foo)
  end

  it "should fail if the object does not respond to method" do
    lambda {
      RespondToSpecs.new.should respond_to(:bar)
    }.should raise_error(Exception)
  end
end
