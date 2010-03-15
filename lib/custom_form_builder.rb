class CustomFormBuilder < ActionView::Helpers::FormBuilder
  include FormHelper

  def submit(value = "Submit", options = {})
    tag = options.delete(:tag)
    tag =~ /button/i ? convert_input_to_button(super) : super
  end

  %w{ text_field text_area password_field select }.each do |helper_name|
    define_method(helper_name) do |*args|
      method, *other_args = *args
      errors_tag = ""
      if object.errors && error = object.errors.on(method)
        for_param = sanitize_to_id([object ? object.class.name.downcase : nil, method].compact.join(' '))
        errors_tag = @template.content_tag(:label, error, :class => "error", :for => for_param)
      end
      add_live_validation_metadata(object, super, *args) + errors_tag
    end
  end

  private
  def sanitize_to_id(name)
    @template.send(:sanitize_to_id, name)
  end

  def add_live_validation_metadata(object, html, *args)
    return html if !object || !object.class.ancestors.include?(ActiveRecord::Base)
    method, *other_args = *args
    doc = Nokogiri::HTML.fragment(html)

    validations = object.class.reflect_on_validations_for(method)
    element = doc.css("input, select, textarea")
    
    if validations.find {|v| v.macro == :validates_presence_of }
      element.add_class("required")
    end
    if validation = validations.find {|v| v.macro == :validates_length_of && v.options[:minimum] }
      element.attr("minlength", validation.options[:minimum].to_s)
      element.add_class("required")
    end
    if validation = validations.find {|v| v.macro == :validates_length_of && v.options[:maxiumum] }
      element.attr("maxlength", validation.options[:maximum].to_s)
      element.add_class("required")
    end
    if validation = validations.find {|v| v.macro == :validates_length_of && v.options[:within] }
      element.attr("minlength", validation.options[:within].first.to_s)
      element.attr("maxlength", validation.options[:within].last.to_s)
      element.add_class("required")
    end
    if validations.find {|v| v.macro == :validates_format_of && v.name.to_s =~ /email_address/i }
      element.add_class("email")
      element.add_class("required")
    end

    doc.to_s
  end
end
