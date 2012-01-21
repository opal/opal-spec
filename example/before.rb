describe "Outer before" do
  before do
    @foo = "foo_ran"
  end

  describe "with an inner before" do
    before do
      @bah = "bah_ran"
    end

    it "should get the outer before hooks run" do
      @foo.should == "foo_ran"
    end

    it "should still run inner befores" do
      @bah.should == "bah_ran"
    end
  end
end
