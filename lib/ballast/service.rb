#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Ballast
  # A class which implements a common abstraction for services.
  #
  # @attribute [r] owner
  #   @return [Object|NilClass] The owner of this service.
  class Service
    # A response to a service invocation.
    #
    # @attribute [r] success
    #   @return [Boolean] Whether the invocation was successful or not.
    # @attribute [r] data
    #   @return [Object] The data returned by the operation.
    # @attribute [r] errors
    #   @return [Array] The errors returned by the operation.
    class Response
      attr_reader :success, :data, :errors

      # Creates a new service response.
      #
      # @param success [Boolean] Whether the invocation was successful or not.
      # @param data [Object|NilClass] The data returned by the operation.
      # @param errors [Array|NilClass] The errors returned by the operation.
      # @param error [Object|NilClass] Alias for errors. *Ignored if `errors` is present.*
      def initialize(success = true, data: nil, errors: nil, error: nil)
        errors ||= error.ensure_array

        @success = success.to_boolean
        @data = data
        @errors = errors.ensure_array(no_duplicates: true, compact: true)
      end

      # Returns whether the invocation was successful or not.
      #
      # @return [Boolean] `true` if the service invocation was successful, `false` otherwise.
      def success?
        # TODO@PI: Ignore rubocop on this
        @success
      end
      alias_method :successful?, :success?
      alias_method :succeeded?, :success?

      # Returns whether the invocation failed or not.
      #
      # @return [Boolean] `true` if the service invocation failed, `false` otherwise.
      def fail?
        !@success
      end
      alias_method :failed?, :fail?

      # Returns the first error returned by the operation.
      #
      # @return [Object] The first error returned by the service.
      def error
        @errors.first
      end

      # Converts this response to a AJAX response.
      #
      # @param transport [Object|NilClass] The transport to use for sending. Must respond to `render`, `params`, `request.format` and `performed?`.
      # @return [AjaxResponse] The AJAX response, which will include only the first error.
      def as_ajax_response(transport = nil)
        status, error_message =
            if successful?
              [:ok, nil]
            elsif error.is_a?(Hash)
              [error[:status], error[:error]]
            else
              [:unknown, error]
            end

        AjaxResponse.new(status: status, data: data, error: error_message, transport: transport)
      end
    end

    attr_reader :owner

    # Invokes one of the operations exposed by the service.
    #
    # @param operation [String] The operation to invoke.
    # @param owner [Object|NilClass] The owner of the service.
    # @param raise_errors [Boolean] Whether to raise errors instead of returning a failure.
    # @param params [Hash] The parameters to pass to the service.
    # @param kwargs [Hash] Other modifiers to pass to the service.
    # @param block [Proc] A lambda to pass to the service.
    # @return [Response] The response of the service.
    def self.call(operation = :perform, owner: nil, raise_errors: false, params: {}, **kwargs, &block)
      fail!(status: 501, error: "Unsupported operation #{self}.#{operation}.") unless respond_to?(operation)
      Response.new(true, data: send(operation, owner: owner, params: params, **kwargs, &block))
    rescue Errors::Failure => failure
      handle_failure(failure, raise_errors)
    end

    # Marks the failure of the operation.
    #
    # @param details [Object] The error(s) occurred.
    def self.fail!(details, on_validation: false)
      raise(Errors::Failure, details)
    end

    # Marks the failure of the validation of the operation.
    #
    # @param details [Object] The error(s) occurred.
    def self.fail_validation!(details)
      raise(Errors::ValidationFailure, details)
    end

    # Creates a service object.
    #
    # @param owner [Object|NilClass] The owner of the service.
    def initialize(owner = nil)
      @owner = owner
    end

    # Invokes one of the operations exposed by the service.
    #
    # @param operation [String] The operation to invoke.
    # @param owner [Object|NilClass] The owner of the service.
    # @param raise_errors [Boolean] Whether to raise errors instead of returning a failure.
    # @param params [Hash] The parameters to pass to the service.
    # @param kwargs [Hash] Other modifiers to pass to the service.
    # @param block [Proc] A lambda to pass to the service.
    # @return [Response] The response of the service.
    def call(operation = :perform, owner: nil, raise_errors: false, params: {}, **kwargs, &block)
      # PI: Ignore Roodi on this method
      @owner = owner if owner
      fail!(status: 501, error: "Unsupported operation #{self.class}##{operation}.") unless respond_to?(operation)
      Response.new(true, data: send(operation, params: params, **kwargs, &block))
    rescue Errors::Failure => failure
      self.class.send(:handle_failure, failure, raise_errors)
    end

    # Marks the failure of the operation.
    #
    # @param details [Object] The error(s) occurred.
    def fail!(details)
      raise(Errors::Failure, details)
    end

    # Marks the failure of the validation of the operation.
    #
    # @param details [Object] The error(s) occurred.
    def fail_validation!(details)
      raise(Errors::ValidationFailure, details)
    end

    # Handles a failure.
    #
    # @param failure [Failure] The failure to handle.
    # @param raise_errors [Boolean] If `true` it will simply raise the error, otherwise it will return a failure as as Service::Response.
    # @return [Response] A failure response.
    def self.handle_failure(failure, raise_errors)
      raise_errors ? raise(failure) : Response.new(false, error: failure.details)
    end
  end
end
