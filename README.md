opal-test
=========

opal-test is a port of MiniTest from ruby1.9 which allows for
compatibility with both opal and opalscript. The runner will also be
configured to output to the DOM when running in the browser. The API is
mostly compatible with MiniTest and opal-test aims to implement as much
of MiniTest as possible - `MiniTest::Spec` is also supported.

As opal-test is just meant to run in opal, to require the library you
should just use `require "minitest/autorun"` like usual as opal-test
tries to be completely API compatible with MiniTest.

Simple Unit Test example
------------------------

Running the given file:

```ruby
require 'minitest/unit'

class Testing < MiniTest::Unit::TestCase

  def test_some_passing_method
    assert 1 == 1
  end

  def test_some_bad_method
    assert 1 == 2
  end

end
```

Should print the following:

```
.F

1) Failure:
test_some_bad_method(Testing):
Failed assertion, no message given.
```

Spec Mode
---------

Spec mode is also partially supported, so running:

```ruby
require 'minitest/spec'
require 'minitest/autorun'

describe "SomeTestingClass" do

  it "should misbehave" do
    true.must_equal false
  end

  it "should behave" do
    true.must_equal true
  end
end
```

Should yield:

```
F
.

1) Failure:
test_1_should_misbehave(AnonClass):
Expected: true, Actual: false

2 tests, 2 assertions, 1 failures, 0 errors, 0 skips
```

Rationale
---------

MiniTest contains some parts that make it difficult, although not
impossible, to get running inside opal. It also contains various extra
requirements like an opt-parser that are overkill for small tests to run
inside the browser.

One day opal might just use MiniTest, but for now a clone/port is more
maintainable and easier to get working inside a browser. Also, it allows
us to customize it to make use of the DOM to print out failures in a
nicer way (yay, css gradients!).

