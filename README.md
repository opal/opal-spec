opaltest
=========

opaltest is a wrapper around MiniTest to allow MiniTest to run in opal.
Eventually this wrapper will not be required once opal can run enough
ruby syntax so that MiniTest works without modification.

opaltest does also contain mspec style matchers which will remain even
after the minitest compatibility code is removed.
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
require 'opaltest/unit'

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
require 'opaltest/spec'
require 'opaltest/autorun'

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

