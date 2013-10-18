# opal-spec

opal-spec is a minimal spec lib for opal, inspired by RSpec and MSpec.
It is designed to run on [opal](http://opalrb.org), and provides the
bare minimum to get specs running.

## Writing Specs

Your specs should go into the `/spec` directory of your app. They take
the same form as rspec/mspec:

```ruby
describe MyClass do
  it 'should do some feature' do
    1.should == 1
  end

  it 'does something else' do
    nil.should be_nil
    false.should be_false
    true.should be_true
  end
end
```

### Supported notations

````
* describe "foo" do ... end
* it "should foo" do ... end
* before do ... end
* after do ... end
* let(:foo) { ... }
* async  # see below

* obj.should == other
* obj.should != other
* obj.should be_nil
* obj.should be_true
* obj.should be_false
* obj.should be_kind_of(klass)
* obj.should eq(other)  # compare with :==
* obj.should equal(other)  # compare with :equal?
* obj.should raise_error
* obj.should be_empty
* obj.should respond_to(method)

* obj.should_not xxx
```

###  Async examples

Examples can be async, and need to be defined as so:

```ruby
describe 'MyClass' do
  # normal, sync example
  it 'does something' do
    #...
  end

  # async example
  async 'does something else too' do
    #...
  end
end
```

This just marks the example as being async. To actually handle the async
result, you also need to use a `run_async` call inside some future handler:

```ruby
async 'HTTP requests should work' do
  HTTP.get('users/1.json') do |response|
    run_async {
      response.ok?.should be_true
    }
  end
end
```

The end of the block passed to `run_async` informs opal-spec that you are
done with this test, so it can move on.
