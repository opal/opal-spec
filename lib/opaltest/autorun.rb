require 'opaltest/unit'

##
# If running in the browser then capture test output straight to the
# page.

if RUBY_ENGINE =~ /opal-browser/
  raise "Body not loaded. Add tests into <body> element" unless `document.body`

  def $stdout.puts(*a)
    a.each do |str|
      `var elem = document.createElement('pre');
      elem.textContent == null ? elem.innerText = str : elem.textContent = str;
      elem.style.margin = "0px";
      document.body.appendChild(elem);`
    end
  end # $stdout
end

##
# If autorun is the main file (entry point), then automatically load all
# specs from spec/

if $0 == __FILE__
  Dir['spec/**/*.rb'].each do |spec|
    require spec
  end
end

##
# Autorun behaviour which uses at_exit() to start tests running

MiniTest::Unit.autorun

