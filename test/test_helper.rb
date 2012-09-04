# encoding: UTF-8

require 'rubygems'
require 'bundler'
Bundler.require :server, :client, :test

require 'test/unit'
require 'minitest/mock'

require_relative '../lib/runner'

# Mock all methods.
class MockEverything
  def method_missing(*args)
    true
  end
end

# Taken from: https://github.com/seattlerb/minitest/blob/master/lib/minitest/mock.rb
class Object # :nodoc:

  ##
  # Add a temporary stubbed method replacing +name+ for the duration
  # of the +block+. If +val_or_callable+ responds to #call, then it
  # returns the result of calling it, otherwise returns the value
  # as-is. Cleans up the stub at the end of the +block+.
  #
  #     def test_stale_eh
  #       obj_under_test = Something.new
  #       refute obj_under_test.stale?
  #
  #       Time.stub :now, Time.at(0) do
  #         assert obj_under_test.stale?
  #       end
  #     end

  def stub name, val_or_callable, &block
    new_name = "__minitest_stub__#{name}"

    metaclass = class << self; self; end
    metaclass.send :alias_method, new_name, name
    metaclass.send :define_method, name do |*args|
      if val_or_callable.respond_to? :call then
        val_or_callable.call(*args)
      else
        val_or_callable
      end
    end

    yield
  ensure
    metaclass.send :undef_method, name
    metaclass.send :alias_method, name, new_name
    metaclass.send :undef_method, new_name
  end
end
