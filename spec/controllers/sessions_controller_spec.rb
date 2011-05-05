require 'spec_helper'

describe SessionsController do
  render_views

  describe "GET 'new'" do
    it "should be successful" do
      get :new
      response.should be_success
    end

    it "should have the right title" do
      get :new
      response.should have_selector("title", :content => "Login")
    end
  end

  describe "POST 'create'" do

    describe "with invalid email and password" do
      before(:each) do
        @attr = { :email => "email@example.edu", :password => "invalid" }
      end

      it "should re-render the logging page" do
        post :create, :session => @attr
        response.should render_template('new')
      end

      it "should have the right title" do
        post :create, :session => @attr
        response.should have_selector("title", :content => "Login")
      end

      it "should have a flash.now message" do
        post :create, :session => @attr
        flash.now[:error].should =~ /invalid/i
      end
    end

    describe "with valid email and password" do

      before(:each) do
        @user = Factory(:user, :email => 'test@TEST.edu')
        @attr = { :email => @user.email, :password => @user.password,
                  :remember_me => true}
      end

      it "should log the user in" do
        post :create, :session => @attr
        controller.current_user.should == @user
        controller.should be_logged_in
      end

      it "should remember the user" do
        post :create, :session => @attr
        response.cookies["remember_token"].should_not be_nil
      end

      it "should redirect to the user show page" do
        post :create, :session => @attr
        response.should redirect_to(user_path(@user))
      end

      it "should accept email with only case difference" do
        post :create, :session => @attr.merge({:email => 'TEST@test.edu'})
        controller.current_user.should == @user
        controller.should be_logged_in
      end

      describe "of deactivated user" do
        before(:each) do
          @user.update_attribute(:status, UserStatus::DEACTIVATED)
        end
        it "should log the user in" do
          post :create, :session => @attr
          controller.current_user.should == @user
          controller.should be_logged_in
        end

        it "should reactivate the user" do
          post :create, :session => @attr
          controller.current_user.status.should == UserStatus::ACTIVE
        end

        it "should have correct flash message" do
          post :create, :session => @attr
        flash[:success].should =~ /reactivated/i
        end
      end

      describe "of banned user" do
        before(:each) do
          @user.update_attribute(:status, UserStatus::BANNED)
        end

        it "should re-render the logging page" do
          post :create, :session => @attr
          response.should render_template('new')
        end

        it "should have the right title" do
          post :create, :session => @attr
          response.should have_selector("title", :content => "Login")
        end

        it "should have a flash.now message" do
          post :create, :session => @attr
          flash.now[:error].should =~ /banned/i
        end

      end
    end

    describe "non-persistent login" do

      before(:each) do
        @user = Factory(:user)
        @attr = { :email => @user.email, :password => @user.password,
                  :remember_me => false}
      end

      it "should log the user in" do
        post :create, :session => @attr
        controller.current_user.should == @user
        controller.should be_logged_in
      end

      it "should not remember me" do
        post :create, :session => @attr
        response.cookies["remember_token"].should be_nil
      end
    end

  end

   describe "DELETE 'destroy'" do

    it "should log a user out" do
      test_login(Factory(:user))
      delete :destroy
      controller.should_not be_logged_in
      response.should redirect_to(root_path)
    end
   end

end
