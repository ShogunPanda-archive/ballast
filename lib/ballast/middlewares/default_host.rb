#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Ballast
  # A list of useful middlewares for Rack.
  module Middlewares
    # Converts the host of an IP based request to the default host.
    class DefaultHost
      # Creates a new middleware instance.
      #
      # @param app [Object] A Rack application.
      # @param path [String] The path of a YAML file with default hosts definition per environment.
      def initialize(app, path)
        @app = app
        @hosts = YAML.load_file(path)
      end

      # Executes the middleware.
      #
      # @param env [Hash] A Rack environment.
      def call(env)
        old_host = env["SERVER_NAME"].ensure_string
        new_host = @hosts[ENV.fetch("RACK_ENV", "production")]

        if old_host =~ /^\d/ && new_host
          env["ORIG_SERVER_NAME"] = old_host
          env["ORIG_HTTP_HOST"] = env["HTTP_HOST"].dup
          env["SERVER_NAME"] = new_host
          env["HTTP_HOST"].gsub!(old_host, new_host)
        end

        @app.call(env)
      end
    end
  end
end
