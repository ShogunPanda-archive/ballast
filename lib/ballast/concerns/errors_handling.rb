#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Ballast
  module Concerns
    # A concern to handle errors. It requires the Ajax concern.
    module ErrorsHandling
      extend ActiveSupport::Concern

      # Handles an error in the application.
      #
      # @param exception [Hash|Exception] The exception to handle.
      # @param layout [String] The layout to use to render the error. The `@error` variable will be exposed.
      # @param title [String] The title to set in case of custom errors.
      # @param format [String|Symbol|NilClass] The format of the response.
      def handle_error(exception, layout: "error", title: "Error - Application", format: nil)
        @error =
          if exception.is_a?(Lazier::Exceptions::Debug)
            {status: 503, title: "Debug", error: exception.message, exception: exception}
          elsif exception.is_a?(::Hash)
            exception.reverse_merge({title: title})
          else
            {status: 500, title: "Error - #{exception.class}", error: exception.message, exception: exception}
          end

        send_or_render_error(layout, format)
      end

      private

      # :nodoc:
      def send_or_render_error(layout, format = nil)
        format ||= request.format.to_sym

        if ajax_request? || (format && format.match(/^json/))
          details = {description: @error[:title], backtrace: @error[:exception].safe_send(:backtrace)}
          prepare_ajax_response(status: @error[:status], data: details, error: @error[:error]).reply(format: format)
        else
          render(html: "", status: @error[:status], layout: layout, formats: [:html])
        end
      end
    end
  end
end
