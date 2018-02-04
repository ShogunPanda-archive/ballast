#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

module Ballast
  # A set of concerns to address common issues.
  module Concerns
    # A concern to handle AJAX and HTTP requests.
    module AjaxHandling
      extend ActiveSupport::Concern

      # Checks if the current request is AJAX.
      #
      # @return [Boolean] `true` if the request is AJAX, `false` otherwise.
      def ajax_request?
        request.safe_send(:xhr?).to_boolean || params[:xhr].to_boolean
      end

      # Prepares an AJAX response.
      #
      # @param status [Symbol|Fixnum] The HTTP status of the response.
      # @param data [Object] The data of the response.
      # @param error [Object|NilClass] The error of the response.
      def prepare_ajax_response(status: :ok, data: {}, error: nil)
        Ballast::AjaxResponse.new(status: status, data: data, error: error, transport: self)
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
      #
      # @param allow_origin [String] The value for the `Access-Control-Allow-Origin` header.
      # @param allow_methods [Array] A list of methods for the `Access-Control-Allow-Methods` header.
      # @param allow_headers [String] The value for the `Access-Control-Allow-Headers` header.
      # @param max_age [Float|Fixnum] The value for the `Access-Control-Max-Age` header.
      # @param allow_credentials [Boolean] The value for the `Access-Control-Allow-Credentials` header.
      def allow_cors(allow_origin: "*", allow_methods: [:post, :get, :options], allow_headers: "*", max_age: 1.year, allow_credentials: false)
        headers.merge!({
          "Access-Control-Allow-Origin" => allow_origin,
          "Access-Control-Allow-Methods" => allow_methods.map { |m| m.to_s.upcase }.join(", "),
          "Access-Control-Allow-Headers" => allow_headers,
          "Access-Control-Max-Age" => max_age.to_i.to_s
        })

        headers["Access-Control-Allow-Credentials"] = "true" if allow_credentials
      end

      # Generates a `robots.txt file.
      #
      # @param configuration [Hash|NilClass] An hash of agent and list of paths to include.
      def generate_robots_txt(configuration = nil)
        configuration ||= {"*" => "/"}
        rv = configuration.reduce([]) do |accu, (agent, paths)|
          paths = paths.ensure_array.map { |e| "Disallow: #{e}" }

          accu << "User-agent: #{agent}\n#{paths.join("\n")}"
          accu
        end

        render(text: rv.join("\n\n"), content_type: "text/plain")
      end
      alias_method :disallow_robots, :generate_robots_txt
    end
  end
end
