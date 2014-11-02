#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Ballast
  # Common errors raised by a Rails application.
  module Errors
    # The base error raised from an application.
    #
    # @attribute [r] details
    #   @return [String|Hash] The details of the error. If a Hash, it should contain a status and a list of errors.
    class Base < RuntimeError
      attr_reader :details

      def initialize(details = nil)
        super("")
        @details = details
      end
    end

    # This is raised when an invalid domain is requested.
    class InvalidDomain < Base
    end

    # This is raised when something went wrong during the processing of a operation.
    class Failure < Base
    end

    # This is raised when some invalid parameters are passed to a operation.
    class ValidationFailure < Failure
    end
  end
end
