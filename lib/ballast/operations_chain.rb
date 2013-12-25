#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Ballast
  # A operation made of several operation run sequentially passing the common context. The chain will stop on the first failure.
  #
  # @attribute [r] operations
  #   @return [Array] The list of operations performed.
  class OperationsChain < Operation
    include ::Interactor::Organizer
    attr_reader :operations

    # Performs the chain.
    #
    # @param argument [Object|Context] If is a context, then it will be the context of the operation, unless a blank a context with the object
    #   as owner will be created.
    # @param operations [Array] The list of operations to perform.
    # @param context [NilClass] The context for the operation. *Ignored if `owner_or_context` is a context.*
    # @param params [Hash] The additional parameters for the new context. *Ignored if `owner_or_context` is a context.*
    # @return [Operation] The performed chain.
    def self.perform(argument, operations, context: nil, params: {})
      argument = (context || ::Ballast::Context.build(argument, params)) if !argument.is_a?(::Ballast::Context)
      new(operations, argument).tap(&:perform)
    end

    # Creates a new chain.
    #
    # @param operations [Array] The list of operations to perform.
    # @param context [Context] The context for the chain.
    def initialize(operations, context)
      @context = context
      @operations = operations.ensure_array
      setup
    end
  end
end