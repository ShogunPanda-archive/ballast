#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Ballast
  # A operation represents a single responsibility class. Subclasses should only expose and override the #perform method.
  class Operation
    extend ::Forwardable
    include Interactor
    def_delegators :context, :owner, :errors, :response, :output

    # Performs the operation.
    #
    # @param owner_or_context [Object|Context] If is a context, then it will be the context of the operation, otherwise a blank a context with the object
    #   as owner will be created.
    # @param context [NilClass] The context for the operation. *Ignored if `owner_or_context` is a context.*
    # @param params [Hash] The additional parameters for the new context. *Ignored if `owner_or_context` is a context.*
    # @return [Operation] The performed operation.
    def self.perform(owner_or_context, context: nil, params: {})
      arg = owner_or_context
      arg = (context || ::Ballast::Context.build(owner_or_context, params)) if !arg.is_a?(::Ballast::Context)
      super(arg)
    end

    # Creates a new operation.
    #
    # @param context [Context] The context for the operation.
    def initialize(context)
      @context = context
      setup
    end

    # Sets up the response hash from instance variables.
    #
    # @param force [Boolean] Whether to setup the response even if the operation failed.
    # @return [Hash] The response hash.
    def setup_response(force = false)
      if success? || force then
        vars = instance_variables
        vars.delete(:@context)

        context.response.merge!(vars.reduce({}){ |rv, var|
          rv[var.to_s.gsub(/[:@]/, "")] = instance_variable_get(var)
          rv
        })
      end

      context.response
    end

    # Imports the response hash into the target instance variables.
    #
    # @param target [Object] The target of the import.
    # @param fields [Array] The keys to import.
    # @param overwrite [Boolean] Whether to overwrite existing variables into the target. If set to `false`, any overwrite will raise an `ArgumentError`.
    def import_response(target, *fields, overwrite: true)
      fields.each do |field|
        raise ArgumentError.new(field) if target.instance_variable_get("@#{field}") && !overwrite
        target.instance_variable_set("@#{field}", response[field])
      end
    end

    # Performs the operation handling base errors.
    #
    # @param setup_response_after [Boolean] Whether to setup the response after processing.
    def perform_with_handling(setup_response_after = true)
      begin
        yield
      rescue Lazier::Exceptions::Debug => de
        raise de
      rescue => e
        e.is_a?(::Ballast::Errors::BaseError) ? fail!(e.response) : raise(e)
      end

      setup_response if setup_response_after
    end

    # Marks failure of the operation appending the error to the context.
    #
    # @param error [Object|NilClass] The error to store.
    def fail!(error = nil)
      errors << error if error
      super()
    end

    # Imports the current operation errors into the target's `@error` instance variable or in the flash hash.
    #
    # @param target [Object] The target of the import.
    # @param to_flash [Boolean] If to import the error in the target's flash object rather than the instance variable.
    # @param first_only [Boolean] If to only import the first error.
    def import_error(target, to_flash = true, first_only = true)
      values = errors
      values = values.map {|v| v[:error] } if to_flash
      values = values.first if first_only

      if to_flash then
        target.flash[:error] = values
      else
        target.instance_variable_set(:@error, values)
      end
    end

    # Resolves a numeric error to a human readable message.
    #
    # @param error [BaseError|Fixnum] The error to resolve.
    # @param supported_messages [Hash] The list of supported error codes.
    # @param only_message [Boolean] If to only return the message string rather than a full error hash.
    # @return [String|Hash] The error with a human readable message or the message alone.
    def resolve_error(error, supported_messages = {}, only_message = false)
      code = (error.respond_to?(:response) ? error.response : 500).to_integer(500)
      rv = {status: code, error: supported_messages.fetch(code, "Oops! We're having some issue. Please try again later.")}
      only_message ? rv[:error] : rv
    end

    # If running under eventmachine, run the block in a thread of its threadpool using EM::Synchrony, otherwise run the block normally.
    #
    # @param block [Proc] The block to run.
    def in_em_thread(&block)
      EM.reactor_running? ? EM::Synchrony.defer(&block) : block.call
    end

    # Forwards any missing method to the owner.
    #
    # @param method [Symbol] The method to forward.
    # @param args [Array] The arguments to pass to the method.
    # @param block [Proc] The block to pass to the method.
    def method_missing(method, *args, &block)
      if owner.respond_to?(method)
        owner.send(method, *args, &block)
      else
        super(method, *args, &block)
      end
    end
  end
end