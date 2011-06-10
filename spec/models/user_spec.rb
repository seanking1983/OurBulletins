require 'spec_helper'

require 'csv'

describe User do

  before(:each) do
    @attr = {
            :name => "Example User",
            :email => "user@hawaii.edu",
            :password => 'Abcd1234 `~!@#$%^&*[]{};:"\'<>?,./|\\-=_+',
            :password_confirmation => 'Abcd1234 `~!@#$%^&*[]{};:"\'<>?,./|\\-=_+'
    }
  end

  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end

  it "should require a name" do
    no_name_user = User.new(@attr.merge(:name => ""))
    no_name_user.should_not be_valid
  end

  describe "Email validation" do
    it "should require a email" do
      no_name_user = User.new(@attr.merge(:email => ""))
      no_name_user.should_not be_valid
    end

    it "should accept valid email addresses" do
      addresses = %w[ THE_USER@university.edu first.last@hawaii.manoa.edu]
      addresses.each do |address|
        valid_email_user = User.new(@attr.merge(:email => address))
        valid_email_user.should be_valid
      end
    end

    it "should accept all edu emails" do
      good_user_names = %w[THE_USER first.last First_LAST]
      CSV.foreach("spec/models/edu_emails_list_trim.csv",
                  :col_sep => ";", :skip_blanks => true) do |row|
        # use row here...
        next if (row[1] == nil)
        email = good_user_names[rand(3)] + '@' + (row[1].strip)
        valid_email_user = User.new(@attr.merge(:email => email))
        valid_email_user.should be_valid, row
      end
    end

    it "should reject invalid email addresses" do
      addresses = %w[user@foo.com user@foo,com user_at_foo.org user@foo. user@.foo
                     user@.hawaii.edu user@-hawaii.manoa.edu user@.edu]
      addresses.each do |address|
        invalid_email_user = User.new(@attr.merge(:email => address))
        invalid_email_user.should_not be_valid, address
      end
    end

    it "should reject duplicate email addresses" do
      # Put a user with given email address into the database.
      User.create!(@attr)
      user_with_duplicate_email = User.new(@attr)
      user_with_duplicate_email.should_not be_valid
    end

    it "should reject email addresses identical up to case" do
      upcased_email = @attr[:email].upcase
      User.create!(@attr.merge(:email => upcased_email))
      user_with_duplicate_email = User.new(@attr)
      user_with_duplicate_email.should_not be_valid
    end
  end


  describe "Password validations" do
    it "should require a password" do
      User.new(@attr.merge(:password => '', :password_confirmation => '')).
        should_not be_valid
    end

    it "should require a matching password confirmation" do
      User.new(@attr.merge(:password_confirmation => '1234bcAD')).
        should_not be_valid
    end

    it "should reject short passwords" do
      User.new(@attr.merge(:password => '123bAD',
                           :password_confirmation => '123bAD')).
        should_not be_valid
    end

    it "should reject passwords with no digit" do
      User.new(@attr.merge(:password => 'Nodigtpassword',
                           :password_confirmation => 'Nodigtpassword')).
        should_not be_valid
    end

  end


  describe "password encryption" do

    before(:each) do
      @user = User.create!(@attr)
    end

    it "should have an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end

    it "should set the encrypted password" do
      @user.encrypted_password.should_not be_blank
    end

    it "should be true if the passwords match" do
      @user.has_password?(@attr[:password]).should be_true
    end

    it "should be false if the passwords don't match" do
      @user.has_password?("invalid").should be_false
    end

    describe "authenticate method" do

      it "should return nil on email/password mismatch" do
        wrong_password_user = User.authenticate(@attr[:email], "wrongpass")
        wrong_password_user.should be_nil
      end

      it "should return nil for an email address with no user" do
        nonexistent_user = User.authenticate("bar@foo.com", @attr[:password])
        nonexistent_user.should be_nil
      end

      it "should return the user on email/password match" do
        matching_user = User.authenticate(@attr[:email], @attr[:password])
        matching_user.should == @user
      end
    end
  end

  describe "admin attribute" do

    before(:each) do
      @user = User.create!(@attr)
    end

    it "should respond to admin" do
      @user.should respond_to(:admin)
    end

    it "should not be an admin by default" do
      @user.should_not be_admin
    end

    it "should be convertible to an admin" do
      @user.toggle!(:admin)
      @user.should be_admin
    end
  end

  describe "status attribute" do

    before :each do
      @user = User.create!(@attr)
    end

    it "should have an status attribute" do
      @user.should respond_to(:status)
    end

    it "should be active by default" do
      @user.status.should == UserStatus::ACTIVE
    end

    it "should not be assigned in creation and remain active by default" do
      new_user = User.create!(@attr.merge(:email => 'new@test.edu',
                                          :status => UserStatus::BANNED))
      new_user.status.should == UserStatus::ACTIVE
    end

    it "should reject invalid input" do
      @user.status= -1
      @user.should_not be_valid
    end

  end

  describe "listing associations" do

    before(:each) do
      @user = User.create(@attr)
      @listing1 = Factory(:listing, :user => @user, :created_at => 1.day.ago)
      @listing2 = Factory(:listing, :user => @user, :created_at => 1.hour.ago)
    end

    it "should have a listings attribute" do
      @user.should respond_to(:listings)
    end

    it "should have the right listings in the right order" do
      @user.listings.should == [@listing2, @listing1]
    end
  end

end