describe "All these tests will fail" do
  it "some simple expectations" do
    1.should == 2
  end

  it "some array comparisons" do
    [1, 2, 3].should == nil
  end

  it "be_kind_of expectations" do
    1.should be_kind_of String
  end

  it "be_nil expectation" do
    [].should be_nil
  end

  it "be_true expectation" do
    false.should be_true
  end

  it "be_false expectation" do
    true.should be_false
  end

  it "equal expectation" do
    Object.new.should equal(Object.new)
  end

  it "raise_error expectation" do
    lambda {
      "dont raise"
    }.should raise_error(Exception)
  end

  it "can use backtraces when available" do
    something.should.fail.as.all.these.methods.dont.exist
  end
end
