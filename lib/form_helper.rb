require 'nokogiri'

module FormHelper
  def convert_input_to_button(html)
    doc = Nokogiri::HTML.fragment(html)
    doc.css("input").reject{|input| input["type"] == "hidden" }.each do |input|
      attributes = input.attributes.merge("type" => "submit")
      value = attributes.delete('value')
      button = Nokogiri::HTML::Builder.new do
        button(attributes) { span { span { text value } } }
      end
      input.swap(button.doc.root.to_html)
    end
    doc.to_s
  end
  
  def button_to(*args)
    convert_input_to_button(super)
  end

  def button_to_function(*args)
    convert_input_to_button(super)
  end

  def submit_tag(value = "Save changes", options = {})
    tag = options.delete(:tag)
    tag =~ /button/i ? convert_input_to_button(super) : super
  end
end
