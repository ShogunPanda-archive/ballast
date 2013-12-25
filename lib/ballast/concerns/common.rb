#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Ballast
  module Concerns
    # A concern to handle common tasks in an application.
    module Common
      # Checks if the user is sending any data.
      #
      # @return [Boolean] `true` if the user is sending data, `false` otherwise.
      def sending_data?
        request.post? || request.put?
      end

      # Performs an operation, using itself as owner by default.
      #
      # @param klass [Class] The operation to perform.
      # @param owner [Object] The owner to use. By default it uses itself.
      # @param kwargs [Hash] The arguments for performing.
      # @return [Operation] The performed operation
      def perform_operation(klass, owner = nil, **kwargs)
        @operation = klass.perform(owner || self, **kwargs)
      end

      # Formats a relative date using abbreviation or short formats.
      #
      # @param date [DateTime] The date to format.
      # @param reference [DateTime] The reference date.
      # @param suffix [String] The suffix to add to the formatted date.
      # @return [String] The formatted date.
      def format_short_duration(date, reference = nil, suffix = "")
        reference ||= Time.now
        amount = (reference.to_i - date.to_i).to_i

        if amount <= 0 then
          "now"
        elsif amount < 1.day then
          format_short_amount(amount, suffix)
        elsif amount < 1.year then
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
        if amount < 1.minute then
          "#{amount.floor}s#{suffix}"
        elsif amount < 1.hour then
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
      def format_long_date(date, separator = "•", format = "%I:%M%p %- %b %o, %Y (%:Z)")
        tz = Time.zone
        replacements = {"%-" => separator, "%o" => date.day.ordinalize, "%:Z" => tz.send(tz.uses_dst? && date.dst? ? :dst_name : :name)}
        date.strftime(format).gsub(/%(-|o|(:Z))/) {|r| replacements.fetch(r, r) }
      end

      # Authenticates a user via HTTP, handling the error if the authentication failed.
      #
      # @param area [String] The name of the area.
      # @param title [String] A title for authentication errors.
      # @param message [String] A message for authentication errors.
      # @param authenticator [Proc] A block to verify if authentication is valid.
      def authenticate_user(area = nil, title = nil, message = nil, &authenticator)
        area ||= "Private Area"
        title ||= "Authentication required."
        message ||= "To view this resource you have to authenticate."
        authenticated = authenticate_with_http_basic { |username, password| authenticator.call(username, password) }

        if !authenticated then
          headers["WWW-Authenticate"] = "Basic realm=\"#{area}\""
          handle_error({status: 401, title: title, message: message})
        end
      end
    end
  end
end