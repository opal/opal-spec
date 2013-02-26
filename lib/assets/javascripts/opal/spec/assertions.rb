module OpalTest
  module Assertions

    def assert(test, msg = "Failed assertion, no message given.")
      unless test
        msg = msg.call if Proc === msg
        raise ExpectationNotMetError, msg
      end
      true
    end

    
  end
end
