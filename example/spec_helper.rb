require 'opal/spec/autorun'

if __FILE__ == $0
  Dir['example/**/*.rb'].each { |s| require s }
end
