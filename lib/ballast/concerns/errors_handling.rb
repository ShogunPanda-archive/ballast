#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Ballast
  module Concerns
    # A concern to handle errors.
    module ErrorsHandling
      extend ActiveSupport::Concern

      # Handles an error in the application.
      #
      # @param exception [Hash|Exception] The exception to handle.
      # @param layout [String] The layout to use to render the error.
      # @param title [String] The title to set in case of custom errors.
      def handle_error(exception = nil, layout = "error", title = "Error - Application")
        @error ||= exception

        if @error.is_a?(Lazier::Exceptions::Debug) then
          @error_title = "Debug"
          @error_code = 503
        elsif @error.is_a?(Hash) then
          @error_title = title
          @error_code = @error[:status]
          @error_message = @error[:error]
        else
          @error_title = "Error - #{@error.class.to_s}"
          @error_code = 500
        end

        send_or_render_error(layout)
      end

      private
        # Send an AJAX error o renders it.
        #
        # @param layout [String] The layout to use to render the error.
        def send_or_render_error(layout)
          if is_ajax? then
            data = prepare_ajax(@error_code, {type: @error_title, backtrace: @error.backtrace.join("\n")}, @error_message || @error.message)
            send_ajax(data)
          else
            render(nothing: true, status: @error_code, layout: layout, formats: [:html])
          end
        end
    end
  end
end