#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

require "spec_helper"

describe Ballast::Concerns::AjaxHandling do
  class AjaxMockClass < OpenStruct
    include Ballast::Concerns::AjaxHandling
  end

  subject{ AjaxMockClass.new(response: OpenStruct.new(headers: {}), headers: {}, params: {}, performed?: false) }

  describe "#ajax_request?" do
    it "should return false by default" do
      expect(AjaxMockClass.new(request: {}, params: {}).ajax_request?).to be_falsey
    end

    it "should return true when the request is XHR" do
      expect(AjaxMockClass.new(request: OpenStruct.new(xhr?: true)).ajax_request?).to be_truthy
    end

    it "should return true when the parameter is overriden" do
      expect(AjaxMockClass.new(params: {xhr: true}).ajax_request?).to be_truthy
    end
  end

  describe "#prepare_ajax_response" do
    it "should return a AJAX response" do
      expect(subject.prepare_ajax_response).to be_a(Ballast::AjaxResponse)

      expect(Ballast::AjaxResponse).to receive(:new).with({status: "STATUS", data: "DATA", error: "ERROR", transport: subject})
      subject.prepare_ajax_response(status: "STATUS", data: "DATA", error: "ERROR")
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

    it "should append custom headers values" do
      subject.allow_cors(allow_origin: "ORIGIN", allow_methods: [:first, :second], allow_headers: "_", max_age: 1.day, allow_credentials: true)

      expect(subject.headers).to eq({
        "Access-Control-Allow-Origin" => "ORIGIN",
        "Access-Control-Allow-Methods" => "FIRST, SECOND",
        "Access-Control-Allow-Headers" => "_",
        "Access-Control-Max-Age" => "86400",
        "Access-Control-Allow-Credentials" => "true"
      })
    end
  end

  describe "#generate_robots_txt" do
    it "should generate a robots.txt file which prevents everything by default" do
      expect(subject).to receive(:render).with(text: "User-agent: *\nDisallow: /", content_type: "text/plain")
      subject.disallow_robots
    end

    it "should generate a robots.txt file which prevents everything by default" do
      expect(subject).to receive(:render).with(text: "User-agent: A\nDisallow: B\nDisallow: C\nDisallow: D\n\nUser-agent: E\nDisallow: F\nDisallow: \nDisallow: G", content_type: "text/plain")
      subject.generate_robots_txt({"A"=> ["B", "C", "D"], "E" => ["F", "", "G"]})
    end
  end
end