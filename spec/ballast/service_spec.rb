require "spec_helper"

describe Ballast::Service::Response do
  describe "#initialize" do
    it "should save attributes" do
      subject = Ballast::Service::Response.new("STATUS", data: "DATA", errors: "ERRORS")
      expect(subject.success).to be_falsey
      expect(subject.data).to eq("DATA")
      expect(subject.errors).to eq(["ERRORS"])
    end
  end

  describe "#success?" do
    it "should return if the operation succeeded" do
      expect(Ballast::Service::Response.new(true).success?).to be_truthy
      expect(Ballast::Service::Response.new(false).success?).to be_falsey
    end
  end

  describe "#fail?" do
    it "should return if the operation failed" do
      expect(Ballast::Service::Response.new(true).fail?).to be_falsey
      expect(Ballast::Service::Response.new(false).fail?).to be_truthy
    end
  end

  describe "#error" do
    it "should return the first error" do
      expect(Ballast::Service::Response.new(true, errors: ["A", "B"]).error).to eq("A")
      expect(Ballast::Service::Response.new(true).error).to be_nil
    end
  end

  describe "as_ajax_response" do
    it "should create the right response" do
      expect(Ballast::AjaxResponse).to receive(:new).with(status: :ok, data: "DATA", error: nil, transport: nil)
      Ballast::Service::Response.new(true, data: "DATA", errors: "ERRORS").as_ajax_response

      expect(Ballast::AjaxResponse).to receive(:new).with(status: 403, data: "DATA", error: "ERROR", transport: nil)
      Ballast::Service::Response.new(false, data: "DATA", errors: {status: 403, error: "ERROR"}).as_ajax_response

      expect(Ballast::AjaxResponse).to receive(:new).with(status: :unknown, data: "DATA", error: "ERROR", transport: nil)
      Ballast::Service::Response.new(false, data: "DATA", errors: "ERROR").as_ajax_response

      expect(Ballast::AjaxResponse).to receive(:new).with(status: :unknown, data: "DATA", error: "ERROR", transport: "TRANSPORT")
      Ballast::Service::Response.new(false, data: "DATA", errors: "ERROR").as_ajax_response("TRANSPORT")
    end
  end
end

describe Ballast::Service do
  class DummyService < Ballast::Service
    def self.class_success(owner: nil, params: nil, **kwargs)
      "CLASS_DATA"
    end

    def self.class_failure(**_)
      fail!("NO")
    end

    def instance_success(params: nil, **kwargs)
      self
    end

    def instance_failure
      fail!("NO")
    end
  end

  describe ".call" do
    it "should call the service and return its return value as data of a service response" do
      expect(DummyService).to receive(:class_success).with({owner: "OWNER", params: {a: 1, b: 2}, other: 1}).and_call_original
      response = DummyService.call(:class_success, owner: "OWNER", params: {a: 1, b: 2}, other: 1)
      expect(response).to be_a(Ballast::Service::Response)
      expect(response.success?).to be_truthy
      expect(response.data).to eq("CLASS_DATA")
    end

    it "should fail when the operation is not supported" do
      response = DummyService.call(:class_unknown)
      expect(response).to be_a(Ballast::Service::Response)
      expect(response.failed?).to be_truthy
      expect(response.data).to be_nil
      expect(response.error).to eq({status: 501, error: "Unsupported operation DummyService.class_unknown."})
    end

    it "should raise an exception when the invocation failed and it is asked to" do
      expect { DummyService.call(:class_failure, raise_errors: true) }.to raise_error(Ballast::Errors::Failure)
    end
  end

  describe ".fail!" do
    it "should raise a failure" do
      expect { DummyService.fail!("DETAILS") }.to raise_error(Ballast::Errors::Failure)
    end
  end

  describe ".fail_validation!" do
    it "should raise a validation failure" do
      expect { DummyService.fail_validation!("DETAILS") }.to raise_error(Ballast::Errors::ValidationFailure)
    end
  end

  describe "#initialize" do
    it "should save the onwer" do
      expect(DummyService.new("OWNER").owner).to eq("OWNER")
    end
  end

  describe "#call" do
    it "should update the owner, then call the service and return its return value as data of a service response" do
      expect_any_instance_of(DummyService).to receive(:instance_success).with({params: {a: 1, b: 2}, other: 1}).and_call_original
      response = DummyService.new.call(:instance_success, owner: "OWNER", params: {a: 1, b: 2}, other: 1)
      expect(response).to be_a(Ballast::Service::Response)
      expect(response.success?).to be_truthy
      expect(response.data).to be_a(DummyService)
      expect(response.data.owner).to eq("OWNER")
    end

    it "should fail when the operation is not supported" do
      response = DummyService.new.call(:class_unknown)
      expect(response).to be_a(Ballast::Service::Response)
      expect(response.failed?).to be_truthy
      expect(response.data).to be_nil
      expect(response.error).to eq({status: 501, error: "Unsupported operation DummyService#class_unknown."})
    end

    it "should raise an exception when the invocation failed and it is asked to" do
      expect { DummyService.new.call(:class_failure, raise_errors: true) }.to raise_error(Ballast::Errors::Failure)
    end
  end

  describe "#fail!" do
    it "should raise a failure" do
      expect { DummyService.new.fail!("DETAILS") }.to raise_error(Ballast::Errors::Failure)
    end

    it "should accept status and error keywords" do
      expect { DummyService.new.fail!(status: "STATUS", error: "ERROR") }.to raise_error(Ballast::Errors::Failure) do |error|
        expect(error.details).to eq({status: "STATUS", error: "ERROR"})
      end
    end
  end

  describe "#fail_validation!" do
    it "should raise a validation failure" do
      expect { DummyService.new.fail_validation!("DETAILS") }.to raise_error(Ballast::Errors::ValidationFailure)
    end

    it "should accept status and error keywords" do
      expect { DummyService.new.fail_validation!(status: "STATUS", error: "ERROR") }.to raise_error(Ballast::Errors::ValidationFailure) do |error|
        expect(error.details).to eq({status: "STATUS", error: "ERROR"})
      end
    end
  end
end
