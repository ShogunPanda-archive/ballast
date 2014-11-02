#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Ballast::Errors::Base do
  subject { Ballast::Errors::Base.new("ERROR") }

  describe ".initialize" do
    it "should save the details" do
      expect(subject.message).to eq("")
      expect(subject.details).to eq("ERROR")
    end
  end
end