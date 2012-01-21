describe "All these tests will pass" do
  it "some simple expectations" do
    1.should == 1
    2.should == 2

    [1, 2, 3].should == [1, 2, 3]
    [].should == []

    "foo".should == "foo"
  end

  it "some simple negative expectations" do
    1.should_not == 2
    3.should_not == 1

    [1, 2, 3].should_not == [1, 2, 3, 4]
    [].should_not == [1]

    "foo".should_not == "bar"
  end

  it "should raise exceptions" do
    lambda {
      raise "foo"
    }.should raise_error(Exception)
  end
end
