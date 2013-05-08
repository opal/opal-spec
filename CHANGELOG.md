## edge

*   Remove old TestCase code, and more to pure spec based testing.

## 0.2.15 2013-05-2

*   Remove opal-sprockets dependency and use opal directly for sprockets
    support.

## 0.2.13 2013-02-23

*   Re-write Opal::Spec::Server to inherit from Opal::Server. Opal::Server is
    a standard rack-app which configures Opal and load paths in a more
    consistent manner.

*   Add respond_to and be_empty matchers for Spec.

*   Added Spec::Pending as a standard way to mark specs as not compliant or
    working. Pending specs are simply ignored when running.

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
