#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Ballast
  # A class which loads a list of YAML files in a folder and expose them in a dotted notation.
  #   For each file, only the subsection for the current environment is loaded, so each YAML document should be an hash.
  class Configuration < HashWithIndifferentAccess
    # Creates a new configuration.
    #
    # @param sections [Array] A list of sections to load. Each section name should be the basename (without extension) of a file in the root folder.
    #   Subfolders are not supported.
    # @param root [String] The root folder where look for file. Default is the Rails root.
    # @param environment [String] The environment to load. Default is the Rails environment.
    def initialize(sections: [], root: nil, environment: nil)
      super()
      root ||= Rails.root.to_s
      environment ||= Rails.env

      sections.each do |section|
        content = (YAML.load_file("#{root}/config/#{section}.yml") rescue {}).with_indifferent_access
        self[section] = content[environment]
      end

      self.enable_dotted_access
    end
  end
end