module Ballast
  module Concerns
    module JSONApi
      # A concern to handle JSON API responses.
      module ResponseHandling
        attr_accessor :included

        # Returns the template for a object. It can overriden by setting the `@object_template` variable.
        #
        # @return [String] The template for a object.
        def response_template_for(object)
          return @object_template if @object_template
          object = object.first if object.respond_to?(:first)
          object.class.name.underscore.gsub("/", "_")
        end

        # Returns the metadata for the current response.
        #
        # @param default [Object|NilClass] The default metadata to return if nothing is set.
        # @return [HashWithIndifferentAccess] The metadata for the current response.
        def response_meta(default = nil)
          @meta || default || HashWithIndifferentAccess.new
        end

        # Returns the data for the current response.
        #
        # @param default [Object|NilClass] The default data to return if nothing is set.
        # @return [HashWithIndifferentAccess] The data for the current response.
        def response_data(default = nil)
          @data || default || HashWithIndifferentAccess.new
        end

        # Returns the links for the current response.
        #
        # @param default [Object|NilClass] The default links to return if nothing is set.
        # @return [HashWithIndifferentAccess] The links for the current response.
        def response_links(default = nil)
          @links || default || HashWithIndifferentAccess.new
        end

        # Returns the additionally included objects for the current response.
        #
        # @param default [Object|NilClass] The default included objects to return if nothing is set.
        # @return [HashWithIndifferentAccess] The additionally included objects for the current response.
        def response_included(default = nil)
          controller.included || default || HashWithIndifferentAccess.new
        end

        # Adds a object to the set of included objects.
        #
        # @param object [Object] The object to include.
        # @param template [String|Nilclass] The template to use for rendering. If not set, it's guessed from object class.
        # @return [HashWithIndifferentAccess] The new set of included objects.
        def response_include(object, template = nil)
          controller.included ||= HashWithIndifferentAccess.new
          controller.included[sprintf("%s:%s", response_template_for(object), object.to_param)] = [object, template]
          controller.included
        end

        # Formats a timestamp in ISO 8601 format.
        #
        # @param timestamp [DateTime|Time|Date] The timestamp to format.
        # @return [String] The timestamp in ISO 8601 format.
        def response_timestamp(timestamp)
          timestamp.safe_send(:strftime, "%FT%T.%L%z")
        end
      end
    end
  end
end
