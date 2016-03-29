#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Ballast
  module Concerns
    # A concern to handle common tasks in an application.
    module Common
      # Executes a service.
      #
      # @param klass [Service] The service to execute.
      # @param operation [String] The operation to invoke.
      # @param kwargs [Hash] Parameters passed to the service.
      # @return [Service::Response] The result of the invocation.
      def perform_service(klass, operation = :perform, **kwargs)
        @result = klass.new(self).call(operation, params: params, **kwargs)
      end

      # Checks if the current request wants JSON or JSONP as response.
      #
      # @return [Boolean] `true` if the request is JSON(P), `false` otherwise.
      def json?
        [:json, :jsonp].include?(request.format.to_sym) || params[:json].to_boolean
      end

      # Checks if the user is sending any data.
      #
      # @return [Boolean] `true` if the user is sending data, `false` otherwise.
      def request_data?
        request.post? || request.put? || request.patch?
      end

      # Formats a relative date using abbreviation or short formats.
      #
      # @param date [DateTime] The date to format.
      # @param reference [DateTime|NilClass] The reference date.
      # @param suffix [String] The suffix to add to the formatted date.
      # @return [String] The formatted date.
      def format_short_duration(date, reference: nil, suffix: "")
        amount = (reference || Time.now).to_i - date.to_i

        if amount <= 0
          "now"
        elsif amount < 1.day
          format_short_amount(amount, suffix)
        elsif amount < 1.year
          date.strftime("%b %d")
        else
          date.strftime("%b %d %Y")
        end
      end

      # Formats a short amount of time (less than one hour).
      #
      # @param amount [Fixnum] The amount to format.
      # @param suffix [String] The suffix to add to the formatted amount.
      # @return [String] The formatted amount.
      def format_short_amount(amount, suffix = "")
        if amount < 1.minute
          "#{amount.floor}s#{suffix}"
        elsif amount < 1.hour
          "#{(amount / 60).floor}m#{suffix}"
        else
          "#{(amount / 3600).floor}h#{suffix}"
        end
      end

      # Formats a long date.
      #
      # @param date [DateTime] The date to format.
      # @param separator [String] The separator between date and time.
      # @param format [String] The format of the date, like in strftime. Use `%-` for the separator, `%o` for the ordinalized version of the day of the month
      #   and `%:Z` for the zone name considering also DST.
      def format_long_date(date, separator: "•", format: "%I:%M%p %- %b %o, %Y (%:Z)")
        tz = Time.zone
        replacements = {"%-" => separator, "%o" => date.day.ordinalize, "%:Z" => tz.current_name(tz.uses_dst? && date.dst?)}
        date.strftime(format).gsub(/%(-|o|(:Z))/) { |r| replacements.fetch(r, r) }
      end

      # Authenticates a user via HTTP, handling the error if the authentication failed.
      #
      # @param area [String|NilClass] The name of the area.
      # @param title [String|NilClass] A title for authentication errors.
      # @param message [String|NilClass] A message for authentication errors.
      # @param authenticator [Proc] A block to verify if authentication is valid.
      def authenticate_user(area: nil, title: nil, message: nil, &authenticator)
        return if authenticate_with_http_basic(&authenticator)

        area ||= "Private Area"
        title ||= "Authentication required."
        message ||= "To view this resource you have to authenticate."

        headers["WWW-Authenticate"] = "Basic realm=\"#{area}\""
        handle_error({status: 401, title: title, message: message})
      end
    end
  end
end
