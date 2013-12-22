#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Ballast
  # A context for an operation. It is basically a Hash with few enhancements, like owner, errors and output support.
  class Context < Interactor::Context
    # Builds a new context.
    #
    # @param owner [Object] The owner of this context.
    # @param additional [Hash] Additional parameters to include into the context.
    def self.build(owner, additional = {})
      super({
        owner: owner,
        errors: [],
        output: nil,
        response: HashWithIndifferentAccess.new
      }.merge(additional).ensure_access(:indifferent))
    end

    # Lookups missing methods in the delegatee hash.
    #
    # @param method [Symbol] The method to lookup.
    # @param args [Array] The arguments passed to the method. *This is ignored.*
    # @param block [Proc] The block passed to the method. *This is ignored.*
    # @return [Object] The value for the method, if present.
    def method_missing(method, *args, &block)
      object = __getobj__

      if object[method] then
        object[method]
      else
        super(method, *args, &block)
      end
    end
  end
end