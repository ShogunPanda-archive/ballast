#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Ballast
  # An AJAX response.
  #
  # @attribute status
  #   @return [Symbol|Fixnum] The HTTP status of the response.
  # @attribute data
  #   @return [Object] The data to send to the client.
  # @attribute error
  #   @return [Object] A error message.
  # @attribute transport
  #   @return [Object] The transport to use for sending. Must respond to `render`, `params`, `request.format` and `performed?`.
  class AjaxResponse
    attr_accessor :status, :data, :error, :transport

    # Creates an AJAX response.
    #
    # @param status [Symbol|Fixnum] The HTTP status of the response.
    # @param data [Object] Additional data to append to the response.
    # @param error [Object] A error to append to the response.
    # @param transport [Object] The transport to use for sending. Must respond to `render`, `params`, `request.format` and `performed?`.
    def initialize(status: :ok, data: {}, error: nil, transport: transport)
      @status = status
      @data = data
      @error = error
      @transport = transport
    end

    # Returns the status as a number.
    #
    # @return [Fixnum] The status as a number.
    def numeric_status
      status.is_a?(Fixnum) ? status : Rack::Utils.status_code(status.ensure_string.to_sym)
    end

    # Returns a JSON representation of the response.
    #
    # @param options [Hash] The options to use for serializing. Currently only `original_status` is supported.
    # @return [Hash] A JSON representation of the response.
    def as_json(options = {})
      {
        status: options[:original_status] ? status : numeric_status,
        data: data,
        error: error
      }
    end

    # Sends the response using the transport.
    #
    # @param format [Symbol] The content type of the response.
    # @param pretty_json [Boolean] If JSON response must be pretty formatted.
    def reply(format: :json, pretty_json: false)
      return if transport.performed?

      format, callback, content_type = format_reply(format)
      data = (pretty_json ? Oj.dump(self) : ActiveSupport::JSON.encode(self)) if [:json, :jsonp, :text].include?(format)

      transport.render(format => data, status: numeric_status, callback: callback, content_type: content_type)
    end

    private

    # :nodoc:
    def format_reply(format)
      format = (format || transport.params[:format] || transport.request.format || "json").to_sym
      callback = [:jsonp, :pretty_jsonp].include?(format) ? (transport.params[:callback] || "jsonp#{Time.now.to_i}") : nil
      content_type = (format == :text) ? "text/plain" : nil

      [format, callback, content_type]
    end
  end
end
