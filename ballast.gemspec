#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require File.expand_path("../lib/ballast/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name = "ballast"
  gem.version = Ballast::Version::STRING
  gem.homepage = "http://github.com/ShogunPanda/ballast"
  gem.summary = "A collection of base utilities for Ruby on Rails."
  gem.description = "A collection of base utilities for Ruby on Rails."
  gem.rubyforge_project = "ballast"

  gem.authors = ["Shogun"]
  gem.email = ["shogun@cowtech.it"]
  gem.license = "MIT"

  gem.files = `git ls-files`.split($\)
  gem.executables = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.0"

  gem.add_dependency("actionpack", ">= 4.0.0")
  gem.add_dependency("rack", "~> 1.5.2")
  gem.add_dependency("oj", "~> 2.5.4")
  gem.add_dependency("brauser", "~> 3.2.5")
  gem.add_dependency("interactor", "~> 2.1.0")
  gem.add_dependency("addressable", "~> 2.3.5")
  gem.add_dependency("rack-fiber_pool", ">= 0.9.3")
  gem.add_dependency("em-synchrony", "~> 1.0.3")
end