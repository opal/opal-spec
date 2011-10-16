require 'minitest/unit'

class Time
  def self.now
    42
  end
end

module Kernel
  def print(*a)
    puts *a
  end
end

class String
  def %()
    self
  end
end

