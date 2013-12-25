#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Ballast
  # A small class to match requests basing on the domain.
  #
  # @attribute domains
  #   @return [Array] The list of domains which mark a positive match.
  # @attribute replace_pattern
  #   @return [String|Regexp] A optional pattern to replace in the request host. See `String#gsub`.
  # @attribute replace_string
  #   @return [String] A string to use for replacement in the request host. See `String#gsub`.
  # @attribute replace_block
  #   @return [Proc] A block to use for replacement in the request host. See `String#gsub`.
  class RequestDomainMatcher
    attr_accessor :domains, :replace_pattern, :replace_string, :replace_block

    # Creates a new matcher.
    #
    # @param domains [String|Array] The list of domains which mark a positive match.
    # @param replace_pattern [String|Regexp] A optional pattern to replace in the request host. See `String#gsub`.
    # @param replace_string [String] A string to use for replacement in the request host. See `String#gsub`.
    # @param replace_block [Proc] A block to use for replacement in the request host. See `String#gsub`.
    def initialize(domains, replace_pattern = /\.dev$/, replace_string = "", &replace_block)
      @domains = domains.ensure_array
      @replace_pattern = replace_pattern
      @replace_string = replace_string
      @replace_block = replace_block
    end

    # Matches a request.
    #
    # @param request [ActionDispatch::Request] The request to match.
    # @return [Boolean] `true` if the request matches, `false` otherwise.
    def matches?(request)
      final_host = @replace_block ? request.host.gsub(@replace_pattern, &@replace_block) : request.host.gsub(@replace_pattern, @replace_string)
      @domains.include?(final_host)
    end
  end
end