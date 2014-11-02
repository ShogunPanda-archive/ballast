#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Ballast::Concerns::ErrorsHandling do
  class ErrorsHandlingMockClass
    include Ballast::Concerns::AjaxHandling
    include Ballast::Concerns::ErrorsHandling

    def request
      OpenStruct.new(format: "json")
    end

    def performed?

    end

    def render(*args)

    end
  end

  subject{ ErrorsHandlingMockClass.new }

  describe "#handle_error" do
    it "should handle a custom error" do
      error = {status: "STATUS", error: "ERROR", title: "TITLE"}
      expect(subject).to receive(:send_or_render_error).with("LAYOUT", nil)
      subject.handle_error(error, layout: "LAYOUT", title: "OTHER TITLE")
      expect(subject.instance_variable_get(:@error)).to eq(error)

      error = {status: "STATUS", error: "ERROR"}
      expect(subject).to receive(:send_or_render_error).with("LAYOUT", nil)
      subject.handle_error(error, layout: "LAYOUT", title: "OTHER TITLE")
      expect(subject.instance_variable_get(:@error)).to eq(error.merge({title: "OTHER TITLE"}))
    end

    it "should handle a debug error" do
      error = Lazier::Exceptions::Debug.new("MESSAGE")
      expect(subject).to receive(:send_or_render_error)

      subject.handle_error(error)
      expect(subject.instance_variable_get(:@error)).to eq({status: 503, title: "Debug", error: "MESSAGE", exception: error})
    end

    it "should handle every other error" do
      error = RuntimeError.new("ERROR")
      expect(subject).to receive(:send_or_render_error)

      subject.handle_error(error)
      expect(subject.instance_variable_get(:@error)).to eq({status: 500, title: "Error - RuntimeError", error: "ERROR", exception: error})
    end

    it "should render an AJAX error" do
      expect_any_instance_of(RuntimeError).to receive(:backtrace).and_return(["A", "B"])
      expect(subject).to receive(:ajax_request?).exactly(2).and_return(true, false)

      expect(Ballast::AjaxResponse).to receive(:new).with({status: 500, error: "ERROR", data: {description: "Error - RuntimeError", backtrace: ["A", "B"]}, transport: subject}).and_call_original
      expect(Ballast::AjaxResponse).to receive(:new).with({status: :forbidden, error: "ERROR", data: {description: "TITLE", backtrace: nil}, transport: subject}).and_call_original

      subject.handle_error(RuntimeError.new("ERROR"))
      subject.instance_variable_set(:@error, nil)
      subject.handle_error({title: "TITLE", status: :forbidden, error: "ERROR"}, format: :json)
    end

    it "should render a HTML error" do
      expect(subject).to receive(:ajax_request?).and_return(false)
      expect(subject).to receive(:request).and_return(OpenStruct.new(format: "HTML"))
      expect(subject).to receive(:render).with(html: "", status: 500, layout: "LAYOUT", formats: [:html])
      subject.handle_error(RuntimeError.new("ERROR"), layout: "LAYOUT")
    end
  end
end
