#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Ballast::AjaxResponse do
  describe "#initialize" do
    it "should save arguments" do
      subject = Ballast::AjaxResponse.new(status: "STATUS", data: "DATA", error: "ERROR", transport: "TRANSPORT")

      expect(subject.status).to eq("STATUS")
      expect(subject.data).to eq("DATA")
      expect(subject.error).to eq("ERROR")
      expect(subject.transport).to eq("TRANSPORT")
    end
  end

  describe "#numeric_status" do
    it "should return the status as an integer" do
      expect(Ballast::AjaxResponse.new.numeric_status).to eq(200)
      expect(Ballast::AjaxResponse.new(status: :forbidden).numeric_status).to eq(403)
      expect(Ballast::AjaxResponse.new(status: :whatever).numeric_status).to eq(500)
    end
  end

  describe "#as_json" do
    it "should serialize correctly" do
      subject = Ballast::AjaxResponse.new(data: "DATA", error: "ERROR", transport: "TRANSPORT")
      expect(subject.as_json).to eq({status: 200, data: "DATA", error: "ERROR"})
      expect(subject.as_json(original_status: true)).to eq({status: :ok, data: "DATA", error: "ERROR"})
    end
  end

  describe "#reply" do
    before(:example) do
      @transport = OpenStruct.new(request: OpenStruct.new(format: :json), params: {}, performed?: false)
    end

    subject { Ballast::AjaxResponse.new(status: 200, data: "DATA", error: "ERROR", transport: @transport) }

    it "should setup the right content type for text" do
      expect(@transport).to receive(:render).with(text: "{\"status\":200,\"data\":\"DATA\",\"error\":\"ERROR\"}", status: 200, callback: nil, content_type: "text/plain")
      subject.reply(format: :text)
    end

    it "should set the right callback for JSONP" do
      @transport.params[:callback] = "callback"
      expect(@transport).to receive(:render).with(jsonp: "{\"status\":200,\"data\":\"DATA\",\"error\":\"ERROR\"}", status: 200, callback: "callback", content_type: nil)
      subject.reply(format: :jsonp)
    end

    it "should not include the transport for pretty JSON" do
      subject.status = 403

      expect(@transport).to receive(:render).with(json: "{\n  \"status\":403,\n  \"data\":\"DATA\",\n  \"error\":\"ERROR\"\n}\n", status: 403, callback: nil, content_type: nil)
      subject.reply(format: nil, pretty_json: true)
    end

    it "should fallback to transport request format" do
      subject.status = 403

      expect(@transport).to receive(:render).with(json: "{\"status\":403,\"data\":\"DATA\",\"error\":\"ERROR\"}", status: 403, callback: nil, content_type: nil)
      subject.reply(format: nil)
    end
  end
end