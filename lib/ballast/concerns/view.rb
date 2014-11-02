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
        format("%s %s", controller_path.gsub("/", "-"), action_name)
      end

      # Returns an instance of the browser.
      #
      # @return [Browser] A browser object.
      def browser
        @browser ||= Brauser::Browser.new(request.user_agent, request.headers["Accept-Language"])
      end

      # Checks if the current browser is supported according to a definition YAML file.
      #
      # @param file [String] The configuration file which holds the definitions.
      # @param root [String] The directory that contains the configuration file.
      # @return [Boolean] `true` if the browser is supported, `false` otherwise.
      def browser_supported?(file = "config/supported-browsers.yml", root: nil)
        browser.supported?(((Ballast::Configuration.default_root || root) + "/" + file).to_s)
      end

      # Returns one or all layout parameters.
      #
      # @param key [String|Symbol|NilClass] The parameter to return. If set to `nil`, all the parameters will be returned as an hash.
      # @param default_value [Object] The default value if the parameter is not present.
      # @return [Object|Hash] The parameter or the entire layout parameters hash.
      def layout_params(key = nil, default_value = nil)
        initialize_view_params
        key ? @layout_params.fetch(key, default_value) : @layout_params
      end
      alias_method :layout_param, :layout_params

      # Adds/Replaces layout parameters.
      #
      # @param args [Hash] The new parameters to add.
      def update_layout_params(**args)
        initialize_view_params
        @layout_params.merge!(args)
      end

      # Outputs the Javascript parameters.
      #
      # @param id [String|NilClass|FalseClass] The id for the tag. If `nil` or `false`, the parameters will be returned as an hash.
      # @param tag [Symbol] The tag to use for HTML.
      # @param attribute [Symbol] The attribute to use for the HTML element id.
      # @return [String|Hash] Javascript parameters as HTML or the hash.
      def javascript_params(id = nil, tag: :details, attribute: "data-jid")
        initialize_view_params
        id ? content_tag(tag, @javascript_params.to_json.html_safe, attribute => id) : @javascript_params
      end

      # Appends new Javascript parameters.
      #
      # @param key [String|Symbol] The key of the new parameters. If `nil`, the root will be merged/replaced.
      # @param data [Hash] The data to add.
      # @param replace [Boolean] Whether to replace existing data rather than merge.
      def update_javascript_params(key, data, replace: false)
        initialize_view_params

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

      private

      # :nodoc:
      def initialize_view_params
        @layout_params ||= HashWithIndifferentAccess.new
        @javascript_params ||= HashWithIndifferentAccess.new
      end
    end
  end
end
