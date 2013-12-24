#
# This file is part of the ballast gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Ballast::Errors::BaseError do
  describe ".initialize" do
    it "should propagate the message also as a response" do
      reference = Ballast::Errors::BaseError.new("ERROR")
      expect(reference.message).to eq("ERROR")
      expect(reference.response).to eq("ERROR")
    end
  end
end