#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Ballast::Concerns::Ajax do
  class AjaxMockClass < OpenStruct
    include Ballast::Concerns::Ajax

    def initialize(attrs)
      @operation = OpenStruct.new(attrs.delete(:operation))
      super(attrs)
    end
  end

  subject{ AjaxMockClass.new(response: OpenStruct.new(headers: {}), headers: {}, params: {}, performed?: false) }

  describe "#is_ajax?" do
    it "should return false by default" do
      expect(AjaxMockClass.new(request: {}, params: {}).is_ajax?).to be(false)
    end

    it "should return true when the request is XHR" do
      expect(AjaxMockClass.new(request: OpenStruct.new(xhr?: true)).is_ajax?).to be(true)
    end

    it "should return true when the parameter is overriden" do
      expect(AjaxMockClass.new(params: {xhr: true}).is_ajax?).to be(true)
    end
  end

  describe "#prepare_ajax" do
    it "should return a default hash" do
      expect(subject.prepare_ajax).to be_a(HashWithIndifferentAccess)
      expect(subject.prepare_ajax).to eq({status: :ok}.with_indifferent_access)
    end

    it "should accept overrides for the status" do
      expect(subject.prepare_ajax(:forbidden)).to eq({status: :forbidden}.with_indifferent_access)
    end

    it "should accept overrides for the data" do
      expect(subject.prepare_ajax(:ok, "DATA")).to eq({status: :ok, data: "DATA"}.with_indifferent_access)
    end

    it "should accept overrides for the error" do
      expect(subject.prepare_ajax(:ok, nil, "ERROR")).to eq({status: :ok, error: "ERROR"}.with_indifferent_access)
    end
  end

  describe "#send_ajax" do
    before(:each) do
      allow(subject).to receive(:render) {|args| args}
    end

    it "should prepare the data if the data is not already an Hash" do
      expect(subject).to receive(:prepare_ajax).with(:ok, "DATA").and_call_original
      expect(subject).to receive(:render).with(json: "{\"status\":200,\"data\":\"DATA\"}", status: 200, callback: nil, content_type: nil)
      subject.send_ajax("DATA")
    end

    it "translate HTTP status" do
      expect(Rack::Utils).to receive(:status_code).with(:forbidden).and_call_original
      expect(subject.send_ajax("DATA", status: :forbidden)[:status]).to eq(403)
    end

    it "should setup the right content type for text" do
      expect(subject).to receive(:render).with(text: "{\"status\":200,\"data\":\"DATA\"}", status: 200, callback: nil, content_type: "text/plain")
      subject.send_ajax("DATA", format: :text)
    end

    it "should set the right callback for JSONP" do
      subject.params[:callback] = "callback"
      expect(subject).to receive(:render).with(jsonp: "{\"status\":200,\"data\":\"DATA\"}", status: 200, callback: "callback", content_type: nil)
      subject.send_ajax("DATA", format: :jsonp)
    end
  end

  describe "#update_ajax" do
    it "should merge the data from successful operations" do
      subject = AjaxMockClass.new(operation: {success?: true, response: {data: "DATA"}})
      expect(subject.update_ajax({existing: true})).to eq({existing: true, data: "DATA"})
    end

    it "should merge the data from failed operations" do
      subject = AjaxMockClass.new(operation: {success?: false, errors: ["ERROR"]})
      expect(subject.update_ajax({existing: true})).to eq({existing: true, error: "ERROR"})
    end
  end

  describe "#prevent_caching" do
    it "should append correct headers" do
      subject.prevent_caching

      expect(subject.response.headers).to eq({
        "Cache-Control" => "no-cache, no-store, max-age=0, must-revalidate",
        "Pragma" => "no-cache",
        "Expires" => "Fri, 01 Jan 1990 00:00:00 GMT"
      })
    end
  end

  describe "#allow_cors" do
    it "should append correct headers" do
      subject.allow_cors

      expect(subject.headers).to eq({
        "Access-Control-Allow-Origin" => "*",
        "Access-Control-Allow-Methods" => "POST, GET, OPTIONS",
        "Access-Control-Allow-Headers" => "*",
        "Access-Control-Max-Age" => "31557600"
      })
    end
  end

  describe "#disallow_robots" do
    it "should disallow robots outputting a text view" do
      expect(subject).to receive(:render).with(text: "User-agent: *\nDisallow: /", content_type: "text/plain")
      subject.disallow_robots
    end
  end
end