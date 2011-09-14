Opaltest
========

Opaltest is a port of MiniTest from ruby1.9 which allows for
compatibility with both opal and opalscript. The runner will also be
configured to output to the DOM when running in the browser. The API is
mostly compatible, with the main exception of the top level module being
called `OpalTest`.

Simple Unit Test example
------------------------

Running the given file:

```ruby

require 'opaltest/autorun'

class Testing < OpalTest::Unit::TestCase

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

