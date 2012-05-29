require 'opal-spec'

OpalSpec.on_dom_ready do
  Dir[OpalSpec.autorun_glob].each do |s|
    require s
  end

  OpalSpec::Runner.new.run
end

module OpalSpec
  @autorun_glob = "spec/**/*"

  def self.autorun_glob
    @autorun_glob
  end

  def self.autorun_glob=(glob)
    @autorun_glob = glob
  end
end