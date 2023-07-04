
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "tvdb_party_v2/version"

Gem::Specification.new do |spec|
  spec.name          = "tvdb_party_v2"
  spec.version       = TvdbPartyV2::VERSION
  spec.authors       = ["David Pan"]
  spec.email         = ["davidpanchina@gmail.com"]

  spec.summary       = %q{Simple Ruby library to talk to thetvdb.com's v2 API.}
  spec.description   = %q{Simple Ruby library to talk to thetvdb.com's v2 API.}
  spec.homepage      = "https://github.com/davidpan/tvdb_party_v2"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.2.23"
  spec.add_development_dependency "rake", "~> 13.0"
end
