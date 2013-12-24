#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Ballast::OperationsChain do
  describe ".perform" do
    before(:each) do
      expect_any_instance_of(Ballast::OperationsChain).to receive(:perform)
    end

    it "should initialize with the set of operations and the first argument as context" do
      context = Ballast::Context.new
      expect(Ballast::Context).not_to receive(:build)
      expect(Ballast::OperationsChain).to receive(:new).with([:A, :B, :C], context).and_call_original
      Ballast::OperationsChain.perform(context, [:A, :B, :C])
    end

    it "shuold use the provided owner and context" do
      context = Ballast::Context.new
      expect(Ballast::Context).not_to receive(:build)
      expect(Ballast::OperationsChain).to receive(:new).with([:A, :B, :C], context).and_call_original
      Ballast::OperationsChain.perform(nil, [:A, :B, :C], context: context)
    end

    it "should created the context on the fly if needed" do
      expect(Ballast::Context).to receive(:build).with("A", {a: 1})
      Ballast::OperationsChain.perform("A", [:A, :B, :C], params: {a: 1})
    end
  end
end