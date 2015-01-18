#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require File.expand_path("../lib/ballast/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name = "ballast"
  gem.version = Ballast::Version::STRING
  gem.homepage = "http://sw.cowtech.it/ballast"
  gem.summary = "A collection of base utilities for web frameworks."
  gem.description = "A collection of base utilities for web frameworks."
  gem.rubyforge_project = "ballast"

  gem.authors = ["Shogun"]
  gem.email = ["shogun@cowtech.it"]
  gem.license = "MIT"

  gem.files = `git ls-files`.split($\)
  gem.executables = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.1.0"

  gem.add_dependency("actionpack", "~> 4.1")
  gem.add_dependency("brauser", "~> 4.0")
  gem.add_dependency("addressable", "~> 2.3")
  gem.add_dependency("em-synchrony", "~> 1.0")
  gem.add_dependency("gemoji", "~> 2.1")
end
