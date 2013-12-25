#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Ballast
  module Concerns
    # A concern to help view handling.
    module View
      # Scopes the CSS of the current page using the controller and action name.
      #
      # @return [String] The scoped string.
      def scope_css
        "%s %s" % [controller_path.gsub("/", "-"), action_name]
      end

      # Returns an instance of the browser.
      #
      # @return [Browser] A browser object.
      def browser
        @browser ||= Brauser::Browser.new(request.user_agent)
      end

      # Checks if the current browser is supported according to a definition YAML file.
      #
      # @param conf_file [String] The configuration file which holds the definitions.
      # @return [Boolean] `true` if the browser is supported, `false` otherwise.
      def browser_supported?(conf_file = nil)
        conf_file ||= (Rails.root + "config/supported-browsers.yml").to_s if defined?(Rails)
        browser.supported?(conf_file)
      end

      # Outputs the Javascript parameters.
      #
      # @param id [String|NilClass|FalseClass] The id for the tag. If `nil` or `false`, the parameters will be returned as an hash.
      # @param tag [Symbol] The tag to use for HTML.
      # @return [String|Hash] Javascript parameters as HTML or the hash.
      def javascript_params(id = nil, tag = :details)
        id ? content_tag(tag, @javascript_params.to_json.html_safe, "data-jid" => id): @javascript_params
      end

      # Appends new Javascript parameters.
      #
      # @param key [String|Symbol] The key of the new parameters. If `nil`, the root will be merged/replaced.
      # @param data [Hash] The data to add.
      # @param replace [Boolean] Whether to replace existing data rather than merge.
      def add_javascript_params(key, data, replace = false)
        @javascript_params ||= HashWithIndifferentAccess.new

        if key
          @javascript_params[key] = nil if replace
          @javascript_params[key] ||= {}
          @javascript_params[key].merge!(data)
        elsif replace
          @javascript_params = data.with_indifferent_access
        else
          @javascript_params.merge!(data)
        end
      end
    end
  end
end