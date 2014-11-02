#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Ballast::Concerns::View do
  class ViewMockClass < OpenStruct
    include Ballast::Concerns::View
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
      expect(subject).to receive(:request).exactly(2).and_return(OpenStruct.new(user_agent: "AGENT", headers: {"Accept-Language" => "FOO"}))
      expect(Brauser::Browser).to receive(:new).with("AGENT", "FOO").and_return("BROWSER")
      expect(subject.browser).to eq("BROWSER")
    end
  end

  describe "#browser_supported?" do
    before(:example) do
      expect(subject).to receive(:request).exactly(2).and_return(OpenStruct.new(user_agent: "AGENT", headers: {"Accept-Language" => "FOO"}))
    end

    it "should check if a browser is supported" do
      expect(subject.browser).to receive(:supported?).with(Dir.pwd + "/CONF").and_return("SUPPORTED")
      expect(subject.browser_supported?("CONF")).to eq("SUPPORTED")
    end

    it "should use a default file" do
      expect(subject.browser).to receive(:supported?).with(Dir.pwd + "/config/supported-browsers.yml").and_return(true)
      subject.browser_supported?
    end
  end

  describe "#layout_params" do
    it "should return a single parameter" do
      subject.update_layout_params(a: 1)
      expect(subject.layout_params(:a)).to eq(1)
    end

    it "should return a default value for a missing parameter" do
      subject.update_layout_params(a: 1)
      expect(subject.layout_params(:b, 2)).to eq(2)
    end

    it "should never raise an error" do
      expect(subject.layout_params(:a)).to be_nil
      expect(subject.layout_params(:a, 3)).to eq(3)
    end

    it "should return the entire hash if no arguments are passed" do
      expect(subject.layout_params).to eq({})
      subject.update_layout_params(a: 1)
      expect(subject.layout_params).to eq({"a" => 1})
    end
  end

  describe "#update_layout_params" do
    it "should merge arguments into the existing parameters" do
      expect(subject.layout_params).to eq({})
      subject.update_layout_params(a: 1, b: 2)
      expect(subject.layout_params).to eq({"a" => 1, "b" => 2})
    end
  end

  describe "#javascript_params" do
    before(:example) do
      subject.instance_variable_set(:@javascript_params, {a: "1", b: 2})
    end

    it "should output Javascript as HTML" do
      expect(subject).to receive(:content_tag).with(:tag, '{"a":"1","b":2}', {"data-jid" => "ID"}).and_return("HTML")
      expect(subject.javascript_params("ID", tag: :tag)).to eq("HTML")
    end

    it "should return Javascript as Hash" do
      expect(subject.javascript_params(false)).to eq({a: "1", b: 2})
      expect(subject.javascript_params(nil)).to eq({a: "1", b: 2})
    end
  end

  describe "#update_javascript_params" do
    before(:example) do
      subject.update_javascript_params(:a, {b: 1})
    end

    it "should create an Hash" do
      expect(subject.instance_variable_get(:@javascript_params)).to be_a(HashWithIndifferentAccess)
    end

    it "should add new keys" do
      subject.update_javascript_params(:c, {d: 2})
      expect(subject.instance_variable_get(:@javascript_params)).to eq({a: {b: 1}, c: {d: 2}}.with_indifferent_access)
    end

    it "should merge values for the same key" do
      subject.update_javascript_params(:a, {d: 2})
      expect(subject.instance_variable_get(:@javascript_params)).to eq({a: {b: 1, d: 2}}.with_indifferent_access)
    end

    it "should replace values for same key if requested to" do
      subject.update_javascript_params(:a, {d: 2}, replace: true)
      expect(subject.instance_variable_get(:@javascript_params)).to eq({a: {d: 2}}.with_indifferent_access)
    end

    it "should merge from the root" do
      subject.update_javascript_params(nil, {d: 2})
      expect(subject.instance_variable_get(:@javascript_params)).to eq({a: {b: 1}, d: 2}.with_indifferent_access)
    end

    it "should replace the entire hash" do
      subject.update_javascript_params(nil, {d: 2}, replace: true)
      expect(subject.instance_variable_get(:@javascript_params)).to eq({d: 2}.with_indifferent_access)
    end
  end
end