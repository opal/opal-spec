describe "Outer group" do
  describe "inner group" do
    it "should pass" do
      1.should == 1
    end

    it "should fail" do
      1.should == 2
    end
  end
end
