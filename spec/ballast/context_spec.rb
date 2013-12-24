#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Ballast::Context do
  describe ".build" do
    it "should prepare data" do
      expect(Interactor::Context).to receive(:build).with({owner: "OWNER", errors: [], output: nil, response: an_instance_of(HashWithIndifferentAccess), a: 1, b: 2}.with_indifferent_access)
      Ballast::Context.build("OWNER", {a: 1, b: 2})
    end
  end

  describe "#method_missing" do
    it "should lookup for keys in the object" do
      context = Ballast::Context.build(nil, {output: 1})
      expect(context.output).to eq(1)
      expect { context.input }.to raise_error(NoMethodError)
    end
  end
end