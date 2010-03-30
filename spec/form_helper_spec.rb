require 'spec_helper'

describe FormHelper, :type => :helper do
  describe "#button_to" do
    it "should use a button tag instead of an input" do
      current_dom = Nokogiri::HTML(helper.button_to "test", "#")
      current_dom.at("button[type=submit] > span > span").text.should == "test"
      current_dom.at("input").should_not be_present
    end
  end

  describe "#button_to_function" do
    it "should use a button tag instead of an input" do
      current_dom = Nokogiri::HTML(helper.button_to_function "test", "alert('foo')")
      current_dom.at("button[type=submit] > span > span").text.should == "test"
      current_dom.at("input").should_not be_present
    end
  end

  describe "#submit_tag" do
    it "should use a button tag instead of an input" do
      current_dom = Nokogiri::HTML(helper.submit_tag "test", :tag => "button")
      current_dom.at("button[type=submit] > span > span").text.should == "test"
    end
  end
end
