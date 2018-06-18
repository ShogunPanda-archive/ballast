#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

# A collection of base utilities for web frameworks.
module Ballast
  # The current version of ballast, according to semantic versioning.
  #
  # @see http://semver.org
  module Version
    # The major version.
    MAJOR = 2

    # The minor version.
    MINOR = 2

    # The patch version.
    PATCH = 5

    # The current version of ballast.
    STRING = [MAJOR, MINOR, PATCH].compact.join(".")
  end
end
