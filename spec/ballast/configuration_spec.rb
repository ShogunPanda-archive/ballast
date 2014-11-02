#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Ballast::Configuration do
  describe ".default_root" do
    it "should return the Rails root" do
      stub_const("Rails", OpenStruct.new(root: "ROOT"))
      expect(Ballast::Configuration.default_root).to eq("ROOT")
    end

    it "should fallback to the current working directory" do
      expect(Ballast::Configuration.default_root).to eq(Dir.pwd)
    end
  end

  describe ".default_environment" do
    it "should return the Rails environment" do
      stub_const("Rails", OpenStruct.new(env: "RAILS-ENV"))
      expect(Ballast::Configuration.default_environment).to eq("RAILS-ENV")
    end

    it "should return the Rack environment" do
      old_env = ENV["RACK_ENV"]
      ENV["RACK_ENV"] = "RACK-ENV"

      expect(Ballast::Configuration.default_environment).to eq("RACK-ENV")
      ENV["RACK_ENV"] = old_env
    end

    it "should fallback to production" do
      old_env = ENV["RACK_ENV"]
      ENV["RACK_ENV"] = nil

      expect(Ballast::Configuration.default_environment).to eq("production")
      ENV["RACK_ENV"] = old_env
    end
  end

  describe "#initialize" do
    describe "when root and environment are defined" do
      before(:example) do
        expect(YAML).to receive(:load_file).with("ROOT/config/section_a.yml").and_return({"ENV" => {a: {b: 1}}, "OTHER" => {aa: 3}})
        expect(YAML).to receive(:load_file).with("ROOT/config/section-b.yml").and_return({"ENV" => {c: {d: 2}}, "OTHER" => {cc: 4}})
      end

      it "should load a list of sections" do
        Ballast::Configuration.new("section_a", "section-b", root: "ROOT", environment: "ENV")
      end

      it "should only load specific environment" do
        subject = Ballast::Configuration.new("section_a", "section-b", root: "ROOT", environment: "ENV")
        expect(subject["section_a"].keys).to eq(["a"])
        expect(subject["section_b"].keys).to eq(["c"])
      end
    end

    describe "when root and environment are NOT defined, it should autodetect root and environment" do
      around(:example) do |example|
        old_env = ENV["RACK_ENV"]
        ENV["RACK_ENV"] = nil

        example.call

        ENV["RACK_ENV"] = old_env
      end

      it "should enable dotted access" do
        expect(YAML).to receive(:load_file).with("#{Dir.pwd}/config/section_a.yml").and_return({"production" => {a: {b: 1}}, "OTHER" => {aa: 3}})
        expect(YAML).to receive(:load_file).with("#{Dir.pwd}/config/section-b.yml").and_return({"production" => {c: {d: 2}}, "OTHER" => {cc: 4}})

        subject = Ballast::Configuration.new("section_a", "section-b")

        expect(subject.section_a.a.b).to eq(1)
        expect(subject.section_b.c).to eq({"d" => 2})
        expect { subject.section_a.e }.to raise_error(NoMethodError)
        expect { subject.e }.to raise_error(NoMethodError)
      end
    end
  end
end