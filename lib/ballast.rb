#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

# PI: Ignore flog on this file.

require "brauser"
require "addressable/uri"
require "em-synchrony"
require "rack/utils"
require "emoji"
require "action_view/helpers/capture_helper"
require "action_view/helpers/tag_helper"

Lazier.load!(:hash, :datetime)
Oj.default_options = Oj.default_options.merge(mode: :compat, indent: 2, symbol_keys: true)

require "ballast/errors"
require "ballast/emoji"
require "ballast/ajax_response"
require "ballast/service"
require "ballast/request_domain_matcher"
require "ballast/configuration"
require "ballast/concerns/ajax_handling"
require "ballast/concerns/common"
require "ballast/concerns/view"
require "ballast/concerns/errors_handling"
require "ballast/middlewares/default_host"

# A collection of base utilities for web frameworks.
module Ballast
  # If running under eventmachine, run the block in a thread of its threadpool using EM::Synchrony, otherwise run the block normally.
  #
  # @param start_reactor [Boolean] If start a EM::Synchrony reactor if none is running.
  # @param block [Proc] The block to run.
  def self.in_em_thread(start_reactor = false, &block)
    if EM.reactor_running?
      run_in_thread(&block)
    elsif start_reactor
      EM.synchrony do
        Ballast.in_em_thread(&block)
        EM.stop
      end
    else
      block.call
    end
  end

  private

  # :nodoc:
  def self.run_in_thread(&block)
    EM::Synchrony.defer do
      Fiber.new { block.call }.resume
    end
  end
end
