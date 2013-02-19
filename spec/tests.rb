class SimpleTest < OpalTest::TestCase
  def test_this_should_be_tested
    :pass.should eq(:pass)
  end

  def test_should_also_pass
    1.should == 1
  end
end
