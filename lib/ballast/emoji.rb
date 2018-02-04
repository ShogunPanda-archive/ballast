#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

module Ballast
  # A module to ease emoji handling.
  module Emoji
    # General utility methods.
    #
    # @attribute url_mapper
    #   @return [Proc] The current URL mapper or a default one (which will return the relative URL unmodified).
    module Utils
      attr_accessor :url_mapper

      # Returns the regular expression which matches all the known emojis.
      #
      # @return [Regexp] The regular expression which matches all the known emojis.
      def replace_regex
        @replace_regex ||= /(#{::Emoji.send(:unicodes_index).keys.join("|")})/
      end

      # Replaces all the emojis in the text using the requested mod.
      #
      # @param text [String] The text to manipulate.
      # @param mode [Symbol] The method to use when replacing icons.
      # @param options [Hash] The options to pass to the replacing method.
      # @return [String] The text with all emojis replaced.
      def replace(text, mode: :html, **options)
        mode = :markup unless mode && ::Emoji::Character.new(nil).respond_to?(mode)
        text.ensure_string.gsub(replace_regex) { invoke(::Emoji.find_by_unicode(Regexp.last_match[1]), mode, options) }
      end

      # Lists all the emoji known in a hash.
      #
      # @param keys_method [Symbol] The method to use for keys.
      # @param values_method [Symbol] The method to use for values.
      # @param options [Hash] The options to pass to all methods.
      # @return [Hash] A hash of all known emojis.
      def enumerate(keys_method: :markup, values_method: :html, **options)
        tester = ::Emoji::Character.new(nil)
        keys_method = :markup unless keys_method && tester.respond_to?(keys_method)
        values_method = :html unless values_method && tester.respond_to?(values_method)

        ::Emoji.all.reduce({}) do |accu, icon|
          accu[invoke(icon, keys_method, options)] = invoke(icon, values_method, options)
          accu
        end
      end

      # Returns the URL mapper for the emojis.
      #
      # @return [Proc] The current URL mapper or a default one (which will return the relative URL unmodified).
      def url_mapper
        @url_mapper || ->(url) { url }
      end

      # Returns a absolute URL for a emoji image.
      #
      # @param image [String] The relative URL of the emoji filename.
      # @return [String] The absolute URL of the emoji filename.
      def url_for(image)
        url_mapper.call(image)
      end

      private

      # :nodoc:
      def invoke(subject, method, options)
        subject.method(method).arity == 1 ? subject.send(method, options) : subject.send(method)
      end
    end

    # Extensions for a emoji character.
    module Character
      include ActionView::Helpers::TagHelper
      include ActiveSupport::Concern

      # Returns a markup for the current character.
      #
      # @return [String] The markup for a character.
      def markup
        ":#{name}:"
      end

      # Returns a image URL for the current character.
      #
      # @return [String] The image URL for the current character.
      def url
        ::Emoji.url_for(image_filename)
      end

      # Returns a image tag for the current character.
      # @see ActionView::Helpers::TagHelper#tag
      #
      # @return [String] The options for the tag generation.
      def image_tag(options = {})
        options = options.reverse_merge({alt: markup, title: markup, rel: "tooltip"})
        classes = options[:class].ensure_string.tokenize(pattern: /[\s,]+/, no_duplicates: true)
        classes << "emoji" unless classes.include?("emoji")

        options[:src] = url
        options[:class] = classes.uniq.join(" ")

        tag(:img, options)
      end
      alias_method :image, :url
      alias_method :html, :image_tag
    end
  end
end

::Emoji.extend(Ballast::Emoji::Utils)
::Emoji::Character.include(Ballast::Emoji::Character)
