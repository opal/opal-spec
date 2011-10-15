require 'minitest/unit'

module OpalTest

  class Unit < MiniTest::Unit

    def _run args = []
      suites = TestCase.test_suites

      @test_count = 0
      @assertion_count = 0

      results = run_suites suites

      @test_count      = results.inject(0) { |sum, tc| sum + tc[0] }
      @assertion_count = results.inject(0) { |sum, ac| sum + ac[1] }

      @report.each_with_index do |msg, i|
        puts "\n#{i + 1}) #{msg}"
      end

      puts ""
      status

      false
    end
  end
end

MiniTest::Unit.runner = OpalTest::Unit.new

