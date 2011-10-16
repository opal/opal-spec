#!/usr/bin/ruby -w

require 'minitest/unit'

class Module # :nodoc:
  def infect_an_assertion meth, new_name, dont_flip = false # :nodoc:
    define_method(new_name) do |*args|
      @@current_spec.__send__ meth, self, *args
    end
  end

  ##
  # infect_with_assertions has been removed due to excessive clever.
  # Use infect_an_assertion directly instead.

  def infect_with_assertions(pos_prefix, neg_prefix,
                             skip_re,
                             dont_flip_re = /\c0/,
                             map = {})
    abort "infect_with_assertions is dead. Use infect_an_assertion directly"
  end
end

module Kernel # :nodoc:
  ##
  # Describe a series of expectations for a given target +desc+.
  #
  # TODO: find good tutorial url.
  #
  # Defines a test class subclassing from either MiniTest::Spec or
  # from the surrounding describe's class. The surrounding class may
  # subclass MiniTest::Spec manually in order to easily share code:
  #
  #     class MySpec < MiniTest::Spec
  #       # ... shared code ...
  #     end
  #
  #     class TestStuff < MySpec
  #       it "does stuff" do
  #         # shared code available here"
  #       end
  #       describe "inner stuff" do
  #         it "still does stuff" do
  #           # ...and here
  #         end
  #       end
  #     end

  def describe desc, additional_desc = nil, &block # :doc:
    stack = MiniTest::Spec.describe_stack
    name  = [stack.last, desc, additional_desc].compact.join("::")
    sclas = stack.last || if Class === self && self < MiniTest::Spec then
                            self
                          else
                            MiniTest::Spec.spec_type desc
                          end

    cls = sclas.create name, desc

    stack.push cls
    cls.class_eval(&block)
    stack.pop
    cls
  end
  private :describe
end

##
# MiniTest::Spec -- The faster, better, less-magic spec framework!
#
# For a list of expectations, see MiniTest::Expectations.

class MiniTest::Spec < MiniTest::Unit::TestCase
  ##
  # Contains pairs of matchers and Spec classes to be used to
  # calculate the superclass of a top-level describe. This allows for
  # automatically customizable spec types.
  #
  # See: register_spec_type and spec_type

  TYPES = [[//, MiniTest::Spec]]

  ##
  # Register a new type of spec that matches the spec's description.
  # This method can take either a Regexp and a spec class or a spec
  # class and a block that takes the description and returns true if
  # it matches.
  #
  # Eg:
  #
  #     register_spec_type(/Controller$/, MiniTest::Spec::Rails)
  #
  # or:
  #
  #     register_spec_type(MiniTest::Spec::RailsModel) do |desc|
  #       desc.superclass == ActiveRecord::Base
  #     end

  def self.register_spec_type(*args, &block)
    if block then
      # FIXME:
      # matcher, klass = block, args.first
      matcher = block
      klass = args.first
    else
      # FIXME:
      # matcher, klass = *args
      matcher = args[0]
      klass = args[1]
    end
    TYPES.unshift [matcher, klass]
  end

  ##
  # Figure out the spec class to use based on the spec's description. Eg:
  #
  #     spec_type("BlahController") # => MiniTest::Spec::Rails

  def self.spec_type desc
    # FIXME:
    # remove this
    return MiniTest::Spec

    TYPES.find { |matcher, klass|
      if matcher.respond_to? :call then
        matcher.call desc
      else
        matcher === desc.to_s
      end
    }.last
  end

  @@describe_stack = []
  def self.describe_stack # :nodoc:
    @@describe_stack
  end

  def self.current # :nodoc:
    @@current_spec
  end

  ##
  # Returns the children of this spec.

  def self.children
    @children ||= []
  end

  def initialize name # :nodoc:
    super name
    @@current_spec = self
  end

  def self.nuke_test_methods! # :nodoc:
    self.public_instance_methods.grep(/^test_/).each do |name|
      self.send :undef_method, name
    end
  end

  ##
  # Define a 'before' action. Inherits the way normal methods should.
  #
  # NOTE: +type+ is ignored and is only there to make porting easier.
  #
  # Equivalent to MiniTest::Unit::TestCase#setup.

  def self.before type = :each, &block
    raise "Unsupported before type: #{type}" unless type == :each

    add_setup_hook {|tc| tc.instance_eval(&block) }
  end

  ##
  # Define an 'after' action. Inherits the way normal methods should.
  #
  # NOTE: +type+ is ignored and is only there to make porting easier.
  #
  # Equivalent to MiniTest::Unit::TestCase#teardown.

  def self.after type = :each, &block
    raise "Unsupported after type: #{type}" unless type == :each

    add_teardown_hook {|tc| tc.instance_eval(&block) }
  end

  ##
  # Define an expectation with name +desc+. Name gets morphed to a
  # proper test method name. For some freakish reason, people who
  # write specs don't like class inheritence, so this goes way out of
  # its way to make sure that expectations aren't inherited.
  #
  # This is also aliased to #specify and doesn't require a +desc+ arg.
  #
  # Hint: If you _do_ want inheritence, use minitest/unit. You can mix
  # and matche between assertions and expectations as much as you want.

  def self.it desc = "anonymous", &block
    block ||= proc { skip "(no tests defined)" }

    @specs ||= 0
    @specs += 1

    # FIXME:
    # name = "test_%04d_%s" % [ @specs, desc.gsub(/\W+/, ' ').downcase ]
    name = "test_#{@specs}_#{desc.gsub(/\W+/, '_').downcase}"

    define_method name, &block

    self.children.each do |mod|
      mod.send :undef_method, name if mod.public_method_defined? name
    end
  end

  def self.let name, &block
    define_method name do
      @_memoized ||= {}
      @_memoized.fetch(name) { |k| @_memoized[k] = instance_eval(&block) }
    end
  end

  def self.subject &block
    let :subject, &block
  end

  def self.create name, desc # :nodoc:
    # FIXME:
    # cls = Class.new(self) do
    #   @name = name
    #   @desc = desc
    #
    #   nuke_test_methods!
    # end
    #
    # children << cls
    #
    # cls
    cls = Class.new(self)
    cls.instance_eval do
      @name = name
      @desc = desc

      nuke_test_methods!
    end

    cls
  end

  def self.to_s # :nodoc:
    # FIXME:
    # defined?(@name) ? @name : super
    @name
  end

  # :stopdoc:
  class << self
    attr_reader :desc
    # FIXME:
    # alias :specify :it
    # alias :name :to_s
  end
  # :startdoc:
end

module MiniTest::Expectations

  ##
  # See MiniTest::Assertions#assert_equal
  #
  #    a.must_equal b
  #
  # :method: must_equal

  infect_an_assertion :assert_equal, :must_equal
end

class Object
  include MiniTest::Expectations
end

