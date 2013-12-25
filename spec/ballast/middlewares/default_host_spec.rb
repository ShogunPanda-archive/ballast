#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Ballast::Middlewares::DefaultHost do
  describe "#initialize" do
    it "should save the app and load default hosts" do
      expect(YAML).to receive(:load_file).with("PATH").and_return({"production" => "HOST"})

      subject = Ballast::Middlewares::DefaultHost.new("APP", "PATH")
      expect(subject.instance_variable_get(:@app)).to eq("APP")
      expect(subject.instance_variable_get(:@hosts)).to eq({"production" => "HOST"})
    end
  end

  describe "#call" do
    before(:each) do
      @app = Proc.new { |env| env }
      expect(YAML).to receive(:load_file).with("PATH").and_return({"production" => "HOST"})
      ENV["RACK_ENV"] = "production"
    end

    subject { Ballast::Middlewares::DefaultHost.new(@app, "PATH") }

    it "should correctly replace the IP if the environment is found" do
      expect(subject.call({"SERVER_NAME" => "10.0.0.1", "HTTP_HOST" => "10.0.0.1"})).to eq({"SERVER_NAME" => "HOST", "HTTP_HOST" => "HOST", "ORIG_SERVER_NAME" => "10.0.0.1", "ORIG_HTTP_HOST" => "10.0.0.1"})
    end

    it "should not replace the IP if the environment is not found" do
      ENV["RACK_ENV"] = "staging"
      expect(subject.call({"SERVER_NAME" => "10.0.0.1", "HTTP_HOST" => "10.0.0.1"})).to eq({"SERVER_NAME" => "10.0.0.1", "HTTP_HOST" => "10.0.0.1"})
    end

    it "should not replace a non IP host" do
      expect(subject.call({"SERVER_NAME" => "abc", "HTTP_HOST" => "cde"})).to eq({"SERVER_NAME" => "abc", "HTTP_HOST" => "cde"})

    end
  end
end