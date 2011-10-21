require 'minitest/unit'

class Time
  def self.now
    42
  end
end

class String
  def %()
    self
  end
end

