#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Ballast::Operation do
  describe ".perform" do
    it "should call the superclass implementation with no changes if the first arg is of the right class" do
      context = Ballast::Context.new

      expect(Ballast::Context).not_to receive(:build)

      Ballast::Operation.perform(context)
      Ballast::Operation.perform(nil, context: context)
    end

    it "should create a context on the fly if the first arg is NOT of the right class" do
      expect(Ballast::Context).to receive(:build).with("OWNER", {}).and_return("ONTHEFLY")
      Ballast::Operation.perform("OWNER")
    end
  end

  describe "#initialize" do
    it "should save the context and then call #setup" do
      expect_any_instance_of(Ballast::Operation).to receive(:setup)
      subject = Ballast::Operation.new("CONTEXT")

      expect(subject.context).to eq("CONTEXT")
    end
  end

  describe "#in_em_thread" do
    it "should yield the block in EM::Synchrony thread" do
      counter = 0
      allow(EM).to receive(:reactor_running?).and_return(true)
      expect(EM::Synchrony).to receive(:defer){|&block| block.call }

      Ballast::Operation.new({}).in_em_thread { counter = 1 }
      expect(counter).to eq(1)
    end
  end

  describe "#setup_response" do
    it "should save instance variables into the context response" do
      subject = Ballast::Operation.new(Ballast::Context.build(nil, response: {a: 1, b: 2, c: 3, d: 4}))
      subject.instance_variable_set(:@first, "A")
      subject.instance_variable_set(:@second, "B")
      subject.instance_variable_set(:@third, "C")

      subject.setup_response
      expect(subject.response).to eq({a: 1, b: 2, c: 3, d: 4, first: "A", second: "B", third: "C"}.with_indifferent_access)
    end

    it "should not do anything if interactor failed" do
      subject = Ballast::Operation.new(Ballast::Context.build(nil, response: {a: 1, b: 2, c: 3, d: 4}))
      expect(subject).to receive(:success?).and_return(false)

      subject.instance_variable_set(:@first, "A")
      subject.instance_variable_set(:@second, "B")
      subject.instance_variable_set(:@third, "C")

      subject.setup_response
      expect(subject.response).to eq({a: 1, b: 2, c: 3, d: 4}.with_indifferent_access)
    end
  end

  describe "#import_response" do
    before(:each) do
      @subject = Ballast::Operation.new(Ballast::Context.build(nil, response: {a: 1, b: 2, c: 3, d: 4}))
      @target = Object.new
      @target.instance_variable_set(:@c, 1)
      @target.instance_variable_set(:@d, 2)
    end

    it "should load instance variables from the context response" do
      @subject.import_response(@target, :a, :b)
      expect(@target.instance_variable_get(:@a)).to eq(1)
      expect(@target.instance_variable_get(:@b)).to eq(2)
    end

    it "should overwrite a variable by default" do
      expect { @subject.import_response(@target, :c) }.not_to raise_error
      expect(@target.instance_variable_get(:@c)).to eq(3)
    end

    it "should raise an error if a variable is already defined and overwrite is disabled" do
      expect { @subject.import_response(@target, :c, overwrite: false) }.to raise_error(ArgumentError)
    end
  end

  describe "#perform_with_handling" do
    before(:each) do
      @subject = Ballast::Operation.new({})
    end

    it "should yield the block" do
      expect(@subject).to receive(:setup_response)

      counter = 0
      @subject.perform_with_handling { counter = 1 }
      expect(counter).to eq(1)
    end

    it "should propagate debug dumps" do
      expect { @subject.perform_with_handling { "DEBUG".for_debug } }.to raise_error(Lazier::Exceptions::Debug)
    end

    it "should handle BaseError" do
      expect(@subject).to receive(:setup_response)
      expect(@subject).to receive(:fail!).with("RESPONSE")
      expect { @subject.perform_with_handling { raise Ballast::Errors::BaseError.new("RESPONSE") } }.not_to raise_error
    end

    it "should propagate the error otherwise" do
      expect { @subject.perform_with_handling { raise RuntimeError.new("ERROR") } }.to raise_error(RuntimeError)
    end
  end

  describe "#fail!" do
    it "should append the error and mark the failure" do
      subject = Ballast::Operation.new(Ballast::Context.build(nil))
      subject.fail!("NO")

      expect(subject.failure?).to be(true)
      expect(subject.errors).to eq(["NO"])
    end
  end

  describe "#import_error" do
    before(:each) do
      @subject = Ballast::Operation.new(Ballast::Context.build(nil, errors: [{status: 401, error: "Unauthorized"}, {status: 403, error: "Forbidden"}]))
    end

    it "should set the flash of the target" do
      target = OpenStruct.new(flash: {})
      @subject.import_error(target)
      expect(target.flash[:error]).to eq("Unauthorized")
    end

    it "should set instance variable if request to" do
      target = OpenStruct.new(flash: {})
      @subject.import_error(target, false)
      expect(target.instance_variable_get(:@error)).to eq({status: 401, error: "Unauthorized"}.with_indifferent_access)
    end

    it "should import all errors if requested to" do
      target = OpenStruct.new(flash: {})
      @subject.import_error(target, true, false)
      @subject.import_error(target, false, false)
      expect(target.flash[:error]).to eq(["Unauthorized", "Forbidden"])
      expect(target.instance_variable_get(:@error)).to eq([{status: 401, error: "Unauthorized"}.with_indifferent_access, {status: 403, error: "Forbidden"}.with_indifferent_access])
    end
  end

  describe "#resolve_error" do
    it "should format AJAX error" do
      subject = Ballast::Operation.new({})
      expect(subject.resolve_error(nil)).to eq({status: 500, error: "Oops! We're having some issue. Please try again later."})
      expect(subject.resolve_error("A")).to eq({status: 500, error: "Oops! We're having some issue. Please try again later."})
      expect(subject.resolve_error("A", {500 => "ERROR"})).to eq({status: 500, error: "ERROR"})
      expect(subject.resolve_error(OpenStruct.new(response: 403))).to eq({status: 403, error: "Oops! We're having some issue. Please try again later."})
      expect(subject.resolve_error(OpenStruct.new(response: 403), {403 => "ERROR"})).to eq({status: 403, error: "ERROR"})
    end
  end

  describe "method_missing" do
    it "should forward call to the owner" do
      subject = Ballast::Operation.new(OpenStruct.new(owner: " ABC "))
      expect(subject.strip).to eq("ABC")
      expect { subject.not_strip }.to raise_error(NoMethodError)
    end
  end
end