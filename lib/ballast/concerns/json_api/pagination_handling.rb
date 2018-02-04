#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

module Ballast
  module Concerns
    module JSONApi
      # A concern to handle errors. It requires the Ajax concern.
      module PaginationHandling
        # Paginates a collection.
        #
        # @param collection [ActiveRecord::Relation] The collection to handle.
        # @param sort_field [Symbol] The field to sort on.
        # @param sort_order [Symbol] The sorting order.
        # return [ActiveRecord::Relation] A paginated and sorted collection.
        def paginate(collection, sort_field: :id, sort_order: :desc)
          direction = @cursor.direction
          value = @cursor.value

          # Apply the query
          collection = apply_value(collection, value, sort_field, sort_order)
          collection = collection.limit(@cursor.size).order(sprintf("%s %s", sort_field, sort_order.upcase))

          # If we're fetching previous we reverse the order to make sure we fetch the results adiacents to the previous request,
          # then we reverse results to ensure the order requested
          if direction != "next"
            collection = collection.reverse_order
            collection = collection.reverse
          end

          collection
        end

        # Returns the field used for pagination.
        #
        # @return [Symbol] The field used for pagination.
        def pagination_field
          @pagination_field ||= :id
        end

        # Returns whether pagination should be skipped in templates rendering for JSON API.
        #
        # @return [Boolean] Whether pagination should be skipped.
        def pagination_skip?
          @skip_pagination
        end

        # Returns whether pagination is supported for the current set of objects for JSON API.
        #
        # @return [Boolean] Whether pagination is supported.
        def pagination_supported?
          @objects.respond_to?(:first) && @objects.respond_to?(:last)
        end

        # Returns a URL to get a specific page of the current set of objects.
        #
        # @param key [String] The page to get. Supported values are `next`, `prev`, `previous` and `first`.
        # @return [String] A URL.
        def pagination_url(key = nil)
          exist = @cursor.might_exist?(key, @objects)
          exist ? url_for(request.params.merge(page: @cursor.save(@objects, key, field: pagination_field)).merge(only_path: false)) : nil
        end

        private

        # :nodoc:
        def apply_value(collection, value, sort_field, sort_order)
          if value
            if cursor.use_offset
              collection = collection.offset(value)
            else
              value = DateTime.parse(value, PaginationCursor::TIMESTAMP_FORMAT) if collection.columns_hash[sort_field.to_s].type == :datetime
              collection = collection.where(sprintf("%s %s ?", sort_field, @cursor.operator(sort_order)), value)
            end
          end

          collection
        end
      end
    end
  end
end
