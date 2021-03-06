require "spec_helper"

describe HomeController do
  # render the views in tests.
  render_views

  before (:each) do
    @base_title = "OurBulletins";
  end

  describe "GET 'index'" do
    it "should show a search bar" do
      get 'index'
      response.should be_success
      response.should have_selector("input#search_q[type='text']")
    end
  end

  describe "GET 'contact'" do
    it "should be successful" do
      get 'contact'
      response.should be_success
    end

    it "should have the right title" do
      get 'contact'
      response.should have_selector("title",
                        :content => "Contact Us | " + @base_title)
    end
  end

  describe "GET 'about'" do
    it "should be successful" do
      get 'about'
      response.should be_success
    end

    it "should have the right title" do
      get 'about'
      response.should have_selector("title",
                        :content => "About Us | " + @base_title)
    end
  end

end

