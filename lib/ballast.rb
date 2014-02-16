#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "lazier"
require "brauser"
require "interactor"
require "addressable/uri"
require "rack/utils"
require "rack/fiber_pool"
require "em-synchrony"
require "oj"

Lazier.load!
Oj.default_options = Oj.default_options.merge(mode: :compat, indent: 2, symbol_keys: true)

require "ballast/version" if !defined?(Ballast::Version)
require "ballast/errors"
require "ballast/context"
require "ballast/operation"
require "ballast/operations_chain"
require "ballast/request_domain_matcher"
require "ballast/configuration"
require "ballast/concerns/ajax"
require "ballast/concerns/common"
require "ballast/concerns/view"
require "ballast/concerns/errors_handling"
require "ballast/middlewares/default_host"

module Ballast
  # If running under eventmachine, run the block in a thread of its threadpool using EM::Synchrony, otherwise run the block normally.
  #
  # @param start_reactor [Boolean] If start a EM::Synchrony reactor if none is running.
  # @param block [Proc] The block to run.
  def self.in_em_thread(start_reactor = false, &block)
    if EM.reactor_running? then
      EM::Synchrony.defer do
        Fiber.new { block.call }.resume
      end
    elsif start_reactor then
      EM.synchrony do
        Ballast.in_em_thread(&block)
        EM.stop
      end
    else
      block.call
    end
  end
end