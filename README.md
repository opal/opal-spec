opal-spec
=========

opal-spec is a minimal spec lib for opal, inspired by RSpec and MSpec.
It is designed to run on [opal][http://opalrb.org], and provides the
bare minimum to get specs running.

Change Log
----------

### Edge

* Allow group names to be non-strings
* Nested groups now have outer group name as prefix
* Nested groups should inherit `before` and `after` blocks

### 0.0.2

* Added seperate BrowserFormatter class for cleaner output
* Update Rake tasks to use new Opal::Builder class

### 0.0.1

Initial release
