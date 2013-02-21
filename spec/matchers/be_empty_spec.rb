describe "be_empty" do
  it "should pass if the object is empty?" do
    [].should be_empty
  end

  it "should fail if the object is not empty?" do
    lambda { [1].should be_empty }.should raise_error(Exception)
  end
end
