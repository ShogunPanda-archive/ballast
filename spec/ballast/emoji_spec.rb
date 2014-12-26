require "spec_helper"

describe Ballast::Emoji do
  before(:example) do
    ::Emoji.instance_variable_set(:@replace_regex, nil)
  end

  shared_examples_for(:dummy_url) do
    before(:example) do
      ::Emoji.url_mapper = ->(url) { "URL/#{url}" }
    end
  end

  describe ".replace_regex" do
    it "should return the right regexp" do
      allow(::Emoji).to receive(:unicodes_index).and_return({a: 1, b: 2})
      expect(::Emoji.replace_regex).to eq(/(a|b)/)
    end
  end

  describe ".replace" do
    include_examples :dummy_url

    it "should return unicode replaced using the requested method" do
      expect(::Emoji.replace("Phone: \u{1F4F1}, Cat: \u{1F431}, #1: \u{0031}\u{20e3}, Invalid: \u{0000}.", mode: :markup)).to eq("Phone: :iphone:, Cat: :cat:, #1: 1⃣, Invalid: \u0000.")
      expect(Emoji.replace("Phone: \u{1F4F1}, Cat: \u{1F431}, #1: \u{0031}\u{20e3}, Invalid: \u{0000}.", mode: :url)).to eq("Phone: URL/unicode/1f4f1.png, Cat: URL/unicode/1f431.png, #1: 1⃣, Invalid: \u0000.")
      expect(Emoji.replace("Phone: \u{1F4F1}, Cat: \u{1F431}, #1: \u{0031}\u{20e3}, Invalid: \u{0000}.", mode: :image_tag, rel: :tooltip)).to eq("Phone: <img alt=\":iphone:\" title=\":iphone:\" rel=\"tooltip\" src=\"URL/unicode/1f4f1.png\" class=\"emoji\" />, Cat: <img alt=\":cat:\" title=\":cat:\" rel=\"tooltip\" src=\"URL/unicode/1f431.png\" class=\"emoji\" />, #1: 1⃣, Invalid: \u0000.")
    end

    it "should fallback to markup when the method is not valid" do
      expect(Emoji.replace("Phone: \u{1F4F1}, Cat: \u{1F431}, #1: \u{0031}\u{20e3}, Invalid: \u{0000}.", mode: :invalid)).to eq("Phone: :iphone:, Cat: :cat:, #1: 1⃣, Invalid: \u0000.")
    end
  end

  describe ".enumerate" do
    include_examples :dummy_url

    it "should enumerate all the available icons" do
      expect(Emoji.enumerate(keys_method: :raw, values_method: :url)["\u{1f604}"]).to eq("URL/unicode/1f604.png")
      expect(Emoji.enumerate(values_method: :image_tag, rel: :tooltip)[":smile:"]).to eq("<img alt=\":smile:\" title=\":smile:\" rel=\"tooltip\" src=\"URL/unicode/1f604.png\" class=\"emoji\" />")
    end
  end

  describe ".url_mapper=" do
    it "should set the new mapper" do
      ::Emoji.url_mapper = "A"
      expect(::Emoji.url_mapper).to eq("A")
      ::Emoji.url_mapper = nil
    end
  end

  describe ".url_mapper" do
    it "should return a default mapper" do
      ::Emoji.url_mapper = nil
      expect(::Emoji.url_mapper.call("URL")).to eq("URL")
    end

    it "should use the specified mapper" do
      ::Emoji.url_mapper = ->(url) { url * 2 }
      expect(::Emoji.url_mapper.call("URL")).to eq("URLURL")
    end
  end

  describe ".url_for" do
    it "should return an absolute URL for an image, using the URL mapper" do
      ::Emoji.url_mapper = nil
      expect(::Emoji.url_for("URL")).to eq("URL")

      ::Emoji.url_mapper = ->(url) { url * 2 }
      expect(::Emoji.url_for("URL")).to eq("URLURL")

      ::Emoji.url_mapper = nil
    end
  end

  describe "#markup" do
    it "should return the markup" do
      expect(Emoji.find_by_alias("cat").markup).to eq(":cat:")
      expect(Emoji.find_by_alias("dog").markup).to eq(":dog:")
      expect(Emoji.find_by_unicode("\u{1F430}").markup).to eq(":rabbit:")
    end
  end

  describe "#url" do
    include_examples :dummy_url

    it "should return the URL/" do
      expect(Emoji.find_by_alias("cat").url).to eq("URL/unicode/1f431.png")
      expect(Emoji.find_by_alias("dog").url).to eq("URL/unicode/1f436.png")
      expect(Emoji.find_by_unicode("\u{1F430}").url).to eq("URL/unicode/1f430.png")
    end
  end

  describe "#image_tag" do
    include_examples :dummy_url

    it "should return an image" do
      expect(Emoji.find_by_alias("cat").image_tag).to eq("<img alt=\":cat:\" title=\":cat:\" rel=\"tooltip\" src=\"URL/unicode/1f431.png\" class=\"emoji\" />")
      expect(Emoji.find_by_alias("cat").image_tag(class: "foo")).to eq("<img alt=\":cat:\" title=\":cat:\" rel=\"tooltip\" class=\"foo emoji\" src=\"URL/unicode/1f431.png\" />")
      expect(Emoji.find_by_alias("cat").image_tag(rel: "tooltip1", class: "abc emoji")).to eq("<img alt=\":cat:\" title=\":cat:\" rel=\"tooltip1\" class=\"abc emoji\" src=\"URL/unicode/1f431.png\" />")
    end
  end
end
