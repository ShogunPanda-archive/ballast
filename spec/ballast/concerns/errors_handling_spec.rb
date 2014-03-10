#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Ballast::Concerns::ErrorsHandling do
  class ErrorsHandlingMockClass < OpenStruct
    include Ballast::Concerns::Ajax
    include Ballast::Concerns::ErrorsHandling

    def initialize(attrs)
      @operation = OpenStruct.new(attrs.delete(:operation))
      super(attrs)
    end
  end

  subject{ ErrorsHandlingMockClass.new(response: OpenStruct.new(headers: {}), headers: {}, params: {}, performed?: false) }

  describe "#handle_error" do
    it "should handle a custom error" do
      error = {status: "STATUS", error: "ERROR"}
      expect(subject).to receive(:send_or_render_error).with("LAYOUT", nil)
      subject.handle_error(error, "LAYOUT", "TITLE")

      expect(subject.instance_variable_get(:@error)).to eq(error)
      expect(subject.instance_variable_get(:@error_code)).to eq("STATUS")
      expect(subject.instance_variable_get(:@error_title)).to eq("TITLE")
      expect(subject.instance_variable_get(:@error_message)).to eq("ERROR")
    end

    it "should handle a debug error" do
      expect(subject).to receive(:send_or_render_error)
      subject.handle_error(Lazier::Exceptions::Debug.new("MESSAGE"))

      expect(subject.instance_variable_get(:@error_code)).to eq(503)
      expect(subject.instance_variable_get(:@error_title)).to eq("Debug")
      expect(subject.instance_variable_get(:@error_message)).to be_nil
    end

    it "should handle every other error" do
      expect(subject).to receive(:send_or_render_error)
      subject.handle_error(RuntimeError.new("ERROR"))

      expect(subject.instance_variable_get(:@error_code)).to eq(500)
      expect(subject.instance_variable_get(:@error_title)).to eq("Error - RuntimeError")
      expect(subject.instance_variable_get(:@error_message)).to be_nil
    end

    it "should render an AJAX error" do
      expect_any_instance_of(RuntimeError).to receive(:backtrace).and_return(["A", "B"])
      allow(subject).to receive(:request).and_return(OpenStruct.new(format: :json))
      expect(subject).to receive(:is_ajax?).exactly(2).and_return(true, false)
      
      expect(subject).to receive(:send_ajax).with({status: 500, error: "ERROR", data: {type: "Error - RuntimeError", backtrace: ["A", "B"]}}.with_indifferent_access, {format: :json})
      expect(subject).to receive(:send_ajax).with({status: :forbidden, error: "ERROR", data: {type: "TITLE"}}.with_indifferent_access, {format: :json})

      subject.handle_error(RuntimeError.new("ERROR"), "LAYOUT")
      subject.instance_variable_set(:@error, nil)
      subject.handle_error({title: "TITLE", status: :forbidden, error: "ERROR"}, :json)
    end

    it "should render a HTML error" do
      allow(subject).to receive(:request).and_return(OpenStruct.new(format: :html))
      expect(subject).to receive(:render).with(html: "", status: 500, layout: "LAYOUT", formats: [:html])
      subject.handle_error(RuntimeError.new("ERROR"), "LAYOUT")
    end
  end
end
