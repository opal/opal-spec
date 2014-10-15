def self.describe desc, &block
  OpalSpec::Example.create(desc, block)
end

class Object
  def should(matcher = nil)
    if matcher
      matcher.positive_match? self
    else
      OpalSpec::PositiveOperatorMatcher.new self
    end
  end

  def should_not(matcher = nil)
    if matcher
      matcher.negative_match? self
    else
      OpalSpec::NegativeOperatorMatcher.new self
    end
  end
end
