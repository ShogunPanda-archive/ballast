#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

# A collection of base utilities for Ruby on Rails.
module Ballast
  # The current version of ballast, according to semantic versioning.
  #
  # @see http://semver.org
  module Version
    # The major version.
    MAJOR = 1

    # The minor version.
    MINOR = 8

    # The patch version.
    PATCH = 0

    # The current version of ballast.
    STRING = [MAJOR, MINOR, PATCH].compact.join(".")
  end
end
