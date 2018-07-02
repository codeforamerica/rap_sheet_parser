
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rap_sheet_parser/version"

Gem::Specification.new do |spec|
  spec.name          = "rap_sheet_parser"
  spec.version       = RapSheetParser::VERSION
  spec.authors       = ["Laura Kogler", "Paras Sanghavi"]
  spec.email         = ["lkogler@codeforamerica.org", "paras@codeforamerica.org "]

  spec.summary       = "For parsing California RAP sheet text"
  spec.description   = "This gem takes text from a RAP sheet and parses it into structured data"
  spec.homepage      = "https://github.com/codeforamerica/rap_sheet_parser"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
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

  spec.add_runtime_dependency "treetop"
  spec.add_runtime_dependency "activesupport"
  spec.add_runtime_dependency "activerecord"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "rspec", "~> 3.0"
end
