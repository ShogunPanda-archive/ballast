#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Ballast::Configuration do
  describe "#initialize" do
    before(:each) do
      expect(YAML).to receive(:load_file).with("ROOT/config/section_a.yml").and_return({"ENV" => {a: {b: 1}}, "OTHER" => {aa: 3}})
      expect(YAML).to receive(:load_file).with("ROOT/config/section-b.yml").and_return({"ENV" => {c: {d: 2}}, "OTHER" => {cc: 4}})
    end

    it "should load a list of sections" do
      Ballast::Configuration.new(sections: ["section_a", "section-b"], root: "ROOT", environment: "ENV")
    end

    it "should only load specific environment" do
      subject = Ballast::Configuration.new(sections: ["section_a", "section-b"], root: "ROOT", environment: "ENV")
      expect(subject["section_a"].keys).to eq(["a"])
      expect(subject["section_b"].keys).to eq(["c"])
    end

    it "should enable dotted access" do
      subject = Ballast::Configuration.new(sections: ["section_a", "section-b"], root: "ROOT", environment: "ENV")

      expect(subject.section_a.a.b).to eq(1)
      expect(subject.section_b.c).to eq({"d" => 2})
      expect { subject.section_a.e }.to raise_error(NoMethodError)
      expect { subject.e }.to raise_error(NoMethodError)
    end
  end
end