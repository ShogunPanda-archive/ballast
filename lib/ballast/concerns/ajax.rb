#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Ballast
  # A set of concerns to address common issues.
  module Concerns
    # A concern to handle AJAX and HTTP requests.
    module Ajax
      extend ActiveSupport::Concern

      # Checks if the current request is AJAX.
      #
      # @return [Boolean] `true` if the request is AJAX, `false` otherwise.
      def is_ajax?
        ((request.respond_to?(:xhr?) && request.xhr?) || params[:xhr].to_boolean) ? true : false
      end

      # Prepares an AJAX response.
      #
      # @param status [Symbol|Fixnum] The HTTP status of the response.
      # @param data [Object] Additional data to append to the response.
      # @param error [Object] A error to append to the response.
      def prepare_ajax(status = :ok, data = nil, error = nil)
        rv = {status: status}.ensure_access(:indifferent)
        rv[:error] = error if error.present?
        rv[:data] = data if data.present?
        rv
      end

      # Sends an AJAX response to the client.
      #
      # @param data [Hash] The response to send.
      # @param status [Symbol|Fixnum] The HTTP status of the response, *ignored if already set in data*.
      # @param format [Symbol] The content type of the response.
      # @param pretty_json [Boolean] If JSON response must be pretty formatted.
      def send_ajax(data, status: :ok, format: :json, pretty_json: false)
        if !performed? then
          # Prepare data
          data = prepare_ajax_send(data, status)

          # Setup callback and format
          format, callback, content_type = format_ajax_send(format)
          status = data[:status]

          # Adjust data
          data = (pretty_json ? Oj.dump(data) : ActiveSupport::JSON.encode(data)) if [:json, :jsonp, :text].include?(format)

          # Render
          render(format => data, status: status, callback: callback, content_type: content_type)
        end
      end

      # Updates an AJAX response from a operation, taking either the response data or the first error.
      #
      # @param data [Hash] The current data.
      # @param operation [Operation] The operation to gather data from.
      # @return [Hash] The updated data.
      def update_ajax(data, operation = nil)
        operation ||= @operation
        data.merge!(operation.success? ? {data: operation.response[:data]} : {error: operation.errors.first})
        data
      end

      # Prevents HTTP caching.
      def prevent_caching
        response.headers.merge!({
          "Cache-Control" => "no-cache, no-store, max-age=0, must-revalidate",
          "Pragma" => "no-cache",
          "Expires" => "Fri, 01 Jan 1990 00:00:00 GMT"
        })
      end

      # Allows HTTP Cross-Origin Resource Sharing.
      def allow_cors
        headers.merge!({
          "Access-Control-Allow-Origin" => "*",
          "Access-Control-Allow-Methods" => "POST, GET, OPTIONS",
          "Access-Control-Allow-Headers" => "*",
          "Access-Control-Max-Age" => 1.year.to_i.to_s
        })
      end

      # Disallows web robots.
      def disallow_robots
        render(text: "User-agent: *\nDisallow: /", content_type: "text/plain")
      end

      private
        # Prepares data for sending back to the client.
        #
        # @param data [Object] The data to send back. Can be a full response or partial data.
        # @param status [Symbol|Fixnum] The HTTP status to set if a new response must be created.
        # @return [Hash] An HTTP response.
        def prepare_ajax_send(data, status)
          data = prepare_ajax(status, data) if !data.is_a?(Hash)
          data[:status] ||= status
          data[:status] = Rack::Utils.status_code(data[:status].to_s.to_sym) if !data[:status].is_a?(Fixnum)
          data
        end

        # Sets up parameters to send a response.
        #
        # @param format [Symbol] The format of the data.
        # @return [Array] An array of format, callback and content_type.
        def format_ajax_send(format)
          format = (format || params[:format] || request.format || "json").to_sym
          callback = [:jsonp, :pretty_jsonp].include?(format) ? (params[:callback] || "jsonp#{Time.now.to_i}") : nil
          content_type = (format == :text) ? "text/plain" : nil

          [format, callback, content_type]
        end
    end
  end
end