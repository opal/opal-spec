class SimpleTest < OpalTest::TestCase
  def test_this_should_be_tested
    :pass.should eq(:pass)
  end

  def test_should_also_pass
    1.should == 1
  end

  def test_simple_assertion
    assert true
    assert 42

    lambda { assert nil }.should raise_error(Exception)
    lambda { assert false }.should raise_error(Exception)
  end
end
