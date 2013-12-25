#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Ballast
  # Common errors raised by a Rails application.
  module Errors
    # The base error raised from an application.
    #
    # @attribute [r] response
    #   @return [String|Hash] The response which contains either a message or an hash with status code and a error message.
    class BaseError < RuntimeError
      attr_reader :response

      def initialize(msg = nil)
        super(msg)
        @response = msg
      end
    end

    # This is raised when an invalid domain is requested.
    class InvalidDomain < BaseError
    end

    # This is raised when something went wrong during the processing of a operation.
    class PerformError < BaseError
    end

    # This is raised when some invalid parameters are passed to a operation.
    class ValidationError < BaseError
    end
  end
end