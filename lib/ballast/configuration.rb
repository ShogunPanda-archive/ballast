#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Ballast
  # A class which loads a list of YAML files in a folder and expose them in a dotted notation.
  #   For each file, only the subsection for the current environment is loaded, so each YAML document should be an hash.
  class Configuration < HashWithIndifferentAccess
    # Returns the default root directory to lookup a configuration. It will be the Rails root if set or the current folder.
    #
    # @return [String] The default root directory to lookup a configuration.
    def self.default_root
      defined?(Rails) ? Rails.root.to_s : Dir.pwd
    end

    # Returns the default environment. It will be the first non-nil of the following: Rails environment, the Rack environment or "production".
    #
    # @return [String] The default environment.
    def self.default_environment
      defined?(Rails) ? Rails.env : ENV.fetch("RACK_ENV", "production")
    end

    # Creates a new configuration.
    #
    # @param sections [Array] A list of sections to load. Each section name should be the basename (without extension) of a file in the root folder.
    #   Subfolders are not supported.
    # @param root [String|NilClass] The root folder where look for file.
    # @param environment [String|NilClass] The environment to load.
    def initialize(*sections, root: nil, environment: nil)
      super()
      root ||= ::Ballast::Configuration.default_root
      environment ||= ::Ballast::Configuration.default_environment

      sections.each do |section|
        content = load_section(root, section)
        self[section.underscore] = content.fetch(environment, {})
      end

      enable_dotted_access
    end

    private

    # :nodoc:
    def load_section(root, section)
      YAML.load_file("#{root}/config/#{section}.yml") rescue {}
    end
  end
end
