require 'spec_helper'

describe CustomFormBuilder, :type => :view do
  describe "#submit" do
    it "renders a button when submit is used with the tag: button" do
      code = %{
        <% form_for user do |f| %>
          <%= f.submit 'save', :tag => 'button' %>
        <% end %>
      }
      render :inline => code, :locals => { :user => create_user }
      current_dom.at("button[type=submit]").text.should == 'save'
    end

    it "renders a input when submit is used" do
      code = %{
        <% form_for user do |f| %>
          <%= f.submit 'save' %>
        <% end %>
      }
      render :inline => code, :locals => { :user => create_user }
      current_dom.at("input[type=submit]")["value"].should =='save'
    end
  end

  describe "validations" do
    {:text_field => ["input[type=text]"], :text_area => ["textarea"], :password_field => ["input[type=password]"], :select => ["select", "[['a', 'a']]"]}.each do |method, (tag, params)|
      describe "##{method}" do
        it "should display inline errors when they are present" do
          code = %{
            <% form_for user do |f| %>
              <%= eval "f.#{method} :first_name#{params ? ", #{params}" : ''}" %>
            <% end %>
          }
          user = new_user(:first_name => "")
          user.should_not be_valid
          render :inline => code, :locals => { :user => user }
          current_dom.at("form > span.fieldWithErrors + label.error[for='user_first_name']").text.should == "can't be blank"
        end

        it "appends required to a field when the model has a validates_presence_of" do
          code = %{
            <% form_for user do |f| %>
              <%= eval "f.#{method} :first_name#{params ? ", #{params}" : ''}" %>
            <% end %>
          }
          render :inline => code, :locals => { :user => create_user }
          current_dom.at("form > #{tag}")["class"].should include("required")
        end
        it "appends minlength/maxlength to a field when the model has a validates_length_of" do
          code = %{
            <% form_for user do |f| %>
              <%= eval "f.#{method} :login#{params ? ", #{params}" : ''}" %>
            <% end %>
          }
          render :inline => code, :locals => { :user => create_user }
          current_dom.at("form > #{tag}")["class"].should include("required")
          current_dom.at("form > #{tag}")["minlength"].should == "1"
          current_dom.at("form > #{tag}")["maxlength"].should == "100"
        end
        it "appends minlength to a field when the model has a validates_length_of" do
          code = %{
            <% form_for user do |f| %>
              <%= eval "f.#{method} :password#{params ? ", #{params}" : ''}" %>
            <% end %>
          }
          render :inline => code, :locals => { :user => create_user }
          current_dom.at("form > #{tag}")["class"].should include("required")
          current_dom.at("form > #{tag}")["minlength"].should == "4"
        end
        it "appends email to a field when the model has a validates_format_of and includes email_address in the name of the field" do
          code = %{
            <% form_for user do |f| %>
              <%= eval "f.#{method} :email_address#{params ? ", #{params}" : ''}" %>
            <% end %>
          }
          render :inline => code, :locals => { :user => create_user }
          current_dom.at("form > #{tag}")["class"].should include("required")
          current_dom.at("form > #{tag}")["class"].should include("email")
        end
      end
    end
  end
end
