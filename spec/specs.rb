@passed = 0
@failures = []

def assert(value, message='Not true')
  if value
    @passed += 1
  else
    @failures << message
  end
end

def assert_equal(got, expected, message='Not equal')
  assert(got == expected, message)
end

describe 'Normal group' do
  it 'this should fail' do
    1.should == 2
  end
end

describe "New eql" do
  it "these should both pass" do
    1.should eq(1)
    1.should_not eq(2)
  end

  it "and this should fail" do
    1.should eq(:adam)
  end
end

describe Object do
  it "should output a nice name for classes" do
    1.should eq(1)
  end
end

describe 'Another group' do
  it 'this should pass' do
    1.should == 1
  end

  it 'this should fail' do
    raise "whatever error you like"
  end

  it 'this should pass' do
    true.should be_true
    false.should be_false
    nil.should be_nil
  end

  async 'this should pass (in 0.1 second time)' do
    set_timeout(100) do
      run_async {
        1.should == 1
      }
    end
  end

  async 'this should fail (in 0.1 second time)' do
    set_timeout(100) do
      run_async {
        1.should == 5
      }
    end
  end
end

describe "let" do
  $opal_spec_let_count = 0

  let(:count) { $opal_spec_let_count = $opal_spec_let_count + 1 }

  it "caches the method for the example" do
    count.should eq(1)
    count.should eq(1)
  end

  it "does not cache values between different examples" do
    count.should eq(2)
  end
end

Opal::Spec::Runner.autorun

puts "Assertions: #{@passed + @failures.length}, Passed: #{@passed}, Failures: #{@failures.length}"
