OTest
=====

Otest is a port of MiniTest from ruby1.9 which allows for
compatibility with both opal and opalscript. The runner will also be
configured to output to the DOM when running in the browser. The API is
mostly compatible, with the main exception of the top level module being
called `OTest`.

Simple Unit Test example
------------------------

Running the given file:

```ruby

require 'test/unit'

class Testing < Test::Unit::TestCase

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
require 'otest/spec'
require 'otest/autorun'

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

