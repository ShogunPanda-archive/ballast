#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Ballast
  # Common errors raised by a web application.
  module Errors
    # The base error raised from an application.
    #
    # @attribute [r] details
    #   @return [String|Hash|NilClass] The details of the error. If a Hash, it should contain the keys `status` and `error`.
    class Base < RuntimeError
      attr_reader :details

      # Creates a new error.
      #
      # @param details [String|Hash|NilClass] The details of this error.
      def initialize(details = nil)
        super("")
        @details = details
      end
    end

    # This is raised when an invalid domain is requested.
    class InvalidDomain < Base
    end

    # This is raised when something went wrong during the processing of a operation or a service.
    class Failure < Base
    end

    # This is raised when some invalid parameters are passed to a operation or a service.
    class ValidationFailure < Failure
    end
  end
end
