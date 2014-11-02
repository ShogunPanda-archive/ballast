#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Ballast::Concerns::Common do
  class CommonMockClass < OpenStruct
    include Ballast::Concerns::Common
  end

  subject{ CommonMockClass.new(request: OpenStruct.new(headers: {}), headers: {}, params: {}, performed?: false) }

  describe "#json?" do
    it "should return false by default" do
      expect(CommonMockClass.new(request: OpenStruct.new({format: ""}), params: {}).json?).to be_falsey
    end

    it "should return true when the request is JSON" do
      expect(CommonMockClass.new(request: OpenStruct.new(format: "json")).json?).to be_truthy
    end

    it "should return true when the parameter is overriden" do
      expect(CommonMockClass.new(request: OpenStruct.new({format: ""}), params: {json: true}).json?).to be_truthy
    end
  end

  describe "#request_data?" do
    it "should return the current status" do
      expect(CommonMockClass.new(request: OpenStruct.new(post?: false, put?: false)).request_data?).to be_falsey
      expect(CommonMockClass.new(request: OpenStruct.new(post?: true, put?: false)).request_data?).to be_truthy
      expect(CommonMockClass.new(request: OpenStruct.new(post?: false, put?: true)).request_data?).to be_truthy
    end
  end

  describe "#format_short_duration" do
    it "should format a date" do
      now = DateTime.civil(2013, 12, 9, 15, 6, 00)
      expect(subject.format_short_duration(DateTime.civil(2013, 12, 9, 16, 6, 0), reference: now, suffix: "ago")).to eq("now")
      expect(subject.format_short_duration(DateTime.civil(2013, 12, 9, 15, 5, 58), reference: now, suffix: "")).to eq("2s")
      expect(subject.format_short_duration(DateTime.civil(2013, 12, 9, 15, 3, 0), reference: now, suffix: " in the past")).to eq("3m in the past")
      expect(subject.format_short_duration(DateTime.civil(2013, 12, 9, 8, 6, 0), reference: now, suffix: "")).to eq("7h")
      expect(subject.format_short_duration(DateTime.civil(2013, 5, 3, 15, 6, 0), reference: now, suffix: "")).to eq("May 03")
      expect(subject.format_short_duration(DateTime.civil(2011, 6, 4, 15, 6, 0), reference: now, suffix: "")).to eq("Jun 04 2011")
    end
  end

  describe "#format_long_date" do
    before(:example) do
      expect_any_instance_of(DateTime).to receive(:dst?).and_return(true)
      expect(Time).to receive(:zone).at_least(1).and_return(ActiveSupport::TimeZone["UTC"], ActiveSupport::TimeZone["Pacific Time (US & Canada)"])
    end

    it "should format a date" do
      expect(subject.format_long_date(DateTime.civil(2013, 7, 11, 10, 9, 8))).to eq("10:09AM • Jul 11th, 2013 (UTC)")
      expect(subject.format_long_date(DateTime.civil(2013, 7, 11, 10, 9, 8), separator: "SEP", format: "%F %T %o %- %:Z")).to eq("2013-07-11 10:09:08 11th SEP Pacific Time (US & Canada) (DST)")
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
      expect(subject).to receive(:handle_error).with({status: 401, title: "Authentication required.", message: "To view this resource you have to authenticate."})

      subject.authenticate_user
      expect(subject.headers["WWW-Authenticate"]).to eq("Basic realm=\"Private Area\"")
    end

    it "in case of failure, it should show custom messages" do
      expect(subject).to receive(:authenticate_with_http_basic).and_return(false)
      expect(subject).to receive(:handle_error).with({status: 401, title: "TITLE", message: "MESSAGE"})

      subject.authenticate_user(area: "AREA", title: "TITLE", message: "MESSAGE")
      expect(subject.headers["WWW-Authenticate"]).to eq("Basic realm=\"AREA\"")
    end
  end
end