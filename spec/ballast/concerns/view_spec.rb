#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Ballast::Concerns::View do
  class ViewMockClass < OpenStruct
    include Ballast::Concerns::View

    def initialize(attrs)
      @operation = OpenStruct.new(attrs.delete(:operation))
      super(attrs)
    end
  end

  subject{ ViewMockClass.new(response: OpenStruct.new(headers: {}), headers: {}, params: {}, performed?: false) }

  describe "#scope_css" do
    it "should return the CSS namespace" do
      expect(subject).to receive(:controller_path).and_return("NAME/CONTROLLER")
      expect(subject).to receive(:action_name).and_return("ACTION")
      expect(subject.scope_css).to eq("NAME-CONTROLLER ACTION")
    end
  end

  describe "#browser" do
    it "should return a browser object" do
      expect(subject).to receive(:request).and_return(OpenStruct.new(user_agent: "AGENT"))
      expect(Brauser::Browser).to receive(:new).with("AGENT").and_return("BROWSER")
      expect(subject.browser).to eq("BROWSER")
    end
  end

  describe "#browser_supported?" do
    before(:each) do
      expect(subject).to receive(:request).and_return(OpenStruct.new(user_agent: "AGENT"))
    end

    it "should check if a browser is supported" do
      expect(subject.browser).to receive(:supported?).with("CONF").and_return("SUPPORTED")
      expect(subject.browser_supported?("CONF")).to eq("SUPPORTED")
    end

    it "should use a default file" do
      class Rails
        def self.root
          Pathname.new("ROOT")
        end
      end

      expect(subject.browser).to receive(:supported?).with("ROOT/config/supported-browsers.yml").and_return(true)
      subject.browser_supported?
    end
  end

  describe "#javascript_params" do
    before(:each) do
      subject.instance_variable_set(:@javascript_params, {a: "1", b: 2})
    end

    it "should output Javascript as HTML" do
      expect(subject).to receive(:content_tag).with(:tag, '{"a":"1","b":2}', {"data-jid" => "ID"}).and_return("HTML")
      expect(subject.javascript_params("ID", :tag)).to eq("HTML")
    end

    it "should return Javascript as Hash" do
      expect(subject.javascript_params(false)).to eq({a: "1", b: 2})
      expect(subject.javascript_params(nil)).to eq({a: "1", b: 2})
    end
  end

  describe "#add_javascript_params" do
    before(:each) do
      subject.add_javascript_params(:a, {b: 1})
    end

    it "should create an Hash" do
      expect(subject.instance_variable_get(:@javascript_params)).to be_a(HashWithIndifferentAccess)
    end

    it "should add new keys" do
      subject.add_javascript_params(:c, {d: 2})
      expect(subject.instance_variable_get(:@javascript_params)).to eq({a: {b: 1}, c: {d: 2}}.with_indifferent_access)
    end

    it "should merge values for the same key" do
      subject.add_javascript_params(:a, {d: 2})
      expect(subject.instance_variable_get(:@javascript_params)).to eq({a: {b: 1, d: 2}}.with_indifferent_access)
    end

    it "should replace values for same key if requested to" do
      subject.add_javascript_params(:a, {d: 2}, true)
      expect(subject.instance_variable_get(:@javascript_params)).to eq({a: {d: 2}}.with_indifferent_access)
    end

    it "should merge from the root" do
      subject.add_javascript_params(nil, {d: 2})
      expect(subject.instance_variable_get(:@javascript_params)).to eq({a: {b: 1}, d: 2}.with_indifferent_access)
    end

    it "should replace the entire hash" do
      subject.add_javascript_params(nil, {d: 2}, true)
      expect(subject.instance_variable_get(:@javascript_params)).to eq({d: 2}.with_indifferent_access)
    end
  end
end