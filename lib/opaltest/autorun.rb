require 'opaltest/unit'

MiniTest::Unit.autorun

if $0 == __FILE__
  puts "in main!"
  Dir['spec/**/*.rb'].each do |spec|
    require spec
  end
end

