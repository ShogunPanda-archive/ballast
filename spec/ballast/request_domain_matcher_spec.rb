#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Ballast::RequestDomainMatcher do
  describe ".initialize" do
    it "should save the attributes" do
      block = Proc.new {}
      subject = Ballast::RequestDomainMatcher.new("A", "B", "C", &block)
      expect(subject.domains).to eq(["A"])
      expect(subject.replace_pattern).to eq("B")
      expect(subject.replace_string).to eq("C")
      expect(subject.replace_block).to be(block)
    end
  end

  describe "#matches?" do
    subject { Ballast::RequestDomainMatcher.new(["A", "ABB", "AC"], "B", "C") { |a| a * 2 } }

    it "should correctly match a request" do
      expect(subject.matches?(OpenStruct.new(host: "A"))).to be_truthy
      expect(subject.matches?(OpenStruct.new(host: "AB"))).to be_truthy
      subject.replace_block = nil
      expect(subject.matches?(OpenStruct.new(host: "AB"))).to be_truthy
      expect(subject.matches?(OpenStruct.new(host: "DD"))).to be_falsey
    end
  end
end
