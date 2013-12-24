#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Ballast::Concerns::Common do
  class CommonMockClass < OpenStruct
    include Ballast::Concerns::Common
  end

  class OperationMockClass

  end

  module Actions
    module CommonMockClass
      class Sub
      end
    end
  end

  subject{ CommonMockClass.new(request: OpenStruct.new(headers: {}), headers: {}, params: {}, performed?: false) }

  describe "#sending_data?" do
    it "should return the current status" do
      expect(CommonMockClass.new(request: OpenStruct.new(post?: false, put?: false)).sending_data?).to be(false)
      expect(CommonMockClass.new(request: OpenStruct.new(post?: true, put?: false)).sending_data?).to be(true)
      expect(CommonMockClass.new(request: OpenStruct.new(post?: false, put?: true)).sending_data?).to be(true)
    end
  end

  describe "#perform_operation" do
    it "should perform the requested operation and memoize it" do
      expect(OperationMockClass).to receive(:perform).with("OWNER", a: 1, b: 2).and_return("OPERATION 1")
      expect(OperationMockClass).to receive(:perform).with(subject, c: 3, d: 4).and_return("OPERATION 2")

      subject.perform_operation(OperationMockClass, "OWNER", a: 1, b: 2)
      expect(subject.instance_variable_get(:@operation)).to eq("OPERATION 1")
      subject.perform_operation(OperationMockClass, c: 3, d: 4)
      expect(subject.instance_variable_get(:@operation)).to eq("OPERATION 2")
    end
  end

  describe "#format_short_duration" do
    it "should format a date" do
      now = DateTime.civil(2013, 12, 9, 15, 6, 00)
      expect(subject.format_short_duration(DateTime.civil(2013, 12, 9, 16, 6, 0), now, "ago")).to eq("now")
      expect(subject.format_short_duration(DateTime.civil(2013, 12, 9, 15, 5, 58), now, "")).to eq("2s")
      expect(subject.format_short_duration(DateTime.civil(2013, 12, 9, 15, 3, 0), now, " in the past")).to eq("3m in the past")
      expect(subject.format_short_duration(DateTime.civil(2013, 12, 9, 8, 6, 0), now, "")).to eq("7h")
      expect(subject.format_short_duration(DateTime.civil(2013, 5, 3, 15, 6, 0), now, "")).to eq("May 03")
      expect(subject.format_short_duration(DateTime.civil(2011, 6, 4, 15, 6, 0), now, "")).to eq("Jun 04 2011")
    end
  end

  describe "#format_long_date" do
    around(:each) do |example|
      Timecop.freeze(Date.civil(2013, 7, 11)) { example.call }
    end

    before(:each) do
      expect(Time).to receive(:zone).at_least(1).and_return(ActiveSupport::TimeZone["UTC"], ActiveSupport::TimeZone["Pacific Time (US & Canada)"])
    end

    it "should format a date" do
      expect(subject.format_long_date(DateTime.civil(2013, 7, 11, 10, 9, 8))).to eq("10:09AM • Jul 11th, 2013 (UTC)")
      expect(subject.format_long_date(DateTime.civil(2013, 7, 11, 10, 9, 8), "SEP", "%F %T %o %- %:Z")).to eq("2013-07-11 10:09:08 11th SEP Pacific Time (US & Canada) (DST)")
    end
  end

  describe "#authenticate_user" do
    it "should ask for authentication and yield the authenticator block" do
      output = nil
      expect(subject).to receive(:authenticate_with_http_basic) {|&block| block.call("USER", "PASSWORD") }

      subject.authenticate_user { |*args| output = args }
      expect(output).to eq(["USER", "PASSWORD"])
    end

    it "in case of failure, it should set error" do
      expect(subject).to receive(:authenticate_with_http_basic).and_return(false)
      expect(subject).to receive(:handle_error)
      subject.authenticate_user

      expect(subject.headers["WWW-Authenticate"]).to eq("Basic realm=\"Private Area\"")
      expect(subject.instance_variable_get(:@error_title)).to eq("Authentication required.")
      expect(subject.instance_variable_get(:@error_message)).to eq("To view this resource you have to authenticate.")
      expect(subject.instance_variable_get(:@error_code)).to eq(401)
    end

    it "in case of failure, it should show custom messages" do
      expect(subject).to receive(:authenticate_with_http_basic).and_return(false)
      expect(subject).to receive(:handle_error)
      subject.authenticate_user("AREA", "TITLE", "MESSAGE")

      expect(subject.headers["WWW-Authenticate"]).to eq("Basic realm=\"AREA\"")
      expect(subject.instance_variable_get(:@error_title)).to eq("TITLE")
      expect(subject.instance_variable_get(:@error_message)).to eq("MESSAGE")
    end
  end
end