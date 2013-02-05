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

### Running specs

Loading these specs in a browser won't just work. You need to run them.
The best place to do this is inside `spec/spec_helper.rb`, and with a
simple call:

```ruby
Opal::Spec::Runner.autorun
```

###  Async examples

Examples can be async, and need to be defined as so:

```ruby
  describe 'MyClass' do
    # normal, sync example
    it 'does something' do
      # ...
    end

    # async example
    async 'does something else too' do
      # ...
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

Change Log
----------

### 0.2.7

* Can be built using asset pipeline/sprockets
* BrowserFormatter is now default

### 0.0.3

* Allow group names to be non-strings
* Nested groups now have outer group name as prefix
* Nested groups should inherit `before` and `after` blocks

### 0.0.2

* Added seperate BrowserFormatter class for cleaner output
* Update Rake tasks to use new Opal::Builder class

### 0.0.1

Initial release