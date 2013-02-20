## 0.2.11 2013-02-20

*   Added TestCase class to allow unit tests. OpalTest::Spec now inherits from
    OpalTest::TestCase.

*   Added Spec#let and Spec#subject.

## 0.2.7

*   Can be built using asset pipeline/sprockets.
*   BrowserFormatter is now default.

## 0.0.3

*   Allow group names to be non-strings.
*   Nested groups now have outer group name as prefix.
*   Nested groups should inherit `before` and `after` blocks.

## 0.0.2

*   Added seperate BrowserFormatter class for cleaner output.
*   Update Rake tasks to use new Opal::Builder class.

## 0.0.1

*   Initial Release.
