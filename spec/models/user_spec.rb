require 'spec_helper'

describe User do
  before(:each) do
    @user = FactoryGirl.build(:beyonce)
  end
  it "has a working factory" do\
    @user.save.should be_true
  end

  it "requires a login (netid)" do
    @user.login = ""
    @user.save.should be_false
    @user.login = "bgk1"
    @user.save.should be_true
  end

  it "must have a unique login" do
    @user.save
    @user_doppleganger = FactoryGirl.build(:beyonce)
    @user_doppleganger.save.should be_false
  end

  it "must have a first name" do
    @user.first_name = ""
    @user.save.should be_false
    @user.first_name = "Beyonce"
    @user.save.should be_true
  end

  it "must have a last name" do
    @user.last_name = ""
    @user.save.should be_false
    @user.last_name = "Knowles"
    @user.save.should be_true
  end

  it "must have an affiliation" do
    @user.affiliation = ""
    @user.save.should be_false
    @user.affiliation = "Destiny's Child"
    @user.save.should be_true
  end

  it "must have a phone number" do
    @user.phone = ""
    @user.save.should be_false
    @user.phone = "555-555-5555"
    @user.save.should be_true
  end

  # figure out what the regex is that's actually used in this validation
  it "phone number must be ??" do
    @user.phone = "555-555-5#55"
    @user.save.should be_false
    @user.phone = "55555555"
    @user.save.should be_true
  end

  it "must have an email" do
    @user.email = ""
    @user.save.should be_false
    @user.email = "beyonce.knowles@yale.edu"
    @user.save.should be_true
  end

  # figure out this regex as well in order to ensure that there is good test coverage
  it "email must take the standard email format (sometext@something.something)"
  it "nickname must not have any non-standard characters (see validation)"

  it "nickname may be blank or nil" do
    @user.nickname = nil
    @user.save.should be_true
    @user.nickname = ""
    @user.save.should be_true
  end

  #TODO: figure out why it's allowing me to save with a false param
  it "must accept ToS" do
    @user.terms_of_service_accepted = nil
    @user.save.should be_false
    @user.terms_of_service_accepted = "1"
    @user.save.should be_true
  end

  # this test means nothing if the previous one fails
  it "doesn't have to accept ToS if created by an admin" do
    @user_made_by_admin = FactoryGirl.build(:beyonce, created_by_admin: true, terms_of_service_accepted: false)
    @user_made_by_admin.save.should be_true
  end

  describe ".active" do
    before(:each) do
      @deactivated = FactoryGirl.create(:justin, deleted_at: "2013-01-01 00:00:00" )
      @user.save
    end

    it "should return all active users" do
      User.active.should include(@user)
    end

    it "should not return inactive users" do
      User.active.should_not include(@deactivated)
    end
  end

  describe "#name" do
    it "should return the first and last name joined into one string if no nickname" do
      @user.save
      @user.name.should == "Sasha Fierce Knowles"
    end
    it "should return the nickname in place of first name if user has one specified" do
      @no_nickname = FactoryGirl.create(:justin)
      @no_nickname.name.should == "Justin Timberlake"
    end
  end

  describe "#can_checkout?" do
    it "should return true if user is a checkout person" do
      checkout_person = FactoryGirl.create(:checkout_person)
      checkout_person.can_checkout?.should == true
    end
    it "should return true if user is an admin in admin mode" do
      admin_in_admin_mode = FactoryGirl.create(:admin, adminmode: "1")
      admin_in_admin_mode.can_checkout?.should == true
    end
    it "should return true if user is an admin in checkoutperson mode" do
      admin_in_checkout_mode = FactoryGirl.create(:admin, checkoutpersonmode: "1")
      admin_in_checkout_mode.can_checkout?.should == true
    end
    it "should return false if user is banned" do
      banned_user = FactoryGirl.create(:user, is_banned: true)
      banned_user.can_checkout?.should be_false
    end
    it "should return false if user is normal" do
      @user.save
      @user.can_checkout?.should be_false
    end
    it "should return false if admin in bannedmode" do
      admin_in_bannedmode = FactoryGirl.create(:admin, bannedmode: "1")
      admin_in_bannedmode.can_checkout?.should be_false
    end
    it "should return false if admin in normal mode" do
      admin_in_normalusermode = FactoryGirl.create(:admin, normalusermode: "1")
      admin_in_normalusermode.can_checkout?.should be_false
    end
  end

  describe "#is_admin_in_adminmode?" do
    it "should return true if user is an admin in admin mode" do
      admin_in_admin_mode = FactoryGirl.create(:admin, adminmode: "1")
      admin_in_admin_mode.is_admin_in_adminmode?.should == true
    end
    it "should return false if user is not an admin" do
      @user.save
      @user.is_admin_in_adminmode?.should == false
    end
    it "should return false if user is admin in normalusermode" do
      admin_as_normal_user = FactoryGirl.create(:admin, normalusermode: "1")
      admin_as_normal_user.is_admin_in_adminmode?.should == false
    end
    it "should return false if user is admin in bannedmode" do
      admin_as_banned = FactoryGirl.create(:admin, bannedmode: "1")
      admin_as_banned.is_admin_in_adminmode?.should == false
    end
    it "should return false if user is admin in checkoutpersonmode" do
      admin_as_checkoutperson = FactoryGirl.create(:admin, checkoutpersonmode: "1")
      admin_as_checkoutperson.is_admin_in_adminmode?.should == false
    end
  end

  describe ".is_admin_in_checkoutpersonmode?" do
    it "should return true if user is an admin in checkoutpersonmode" do
      admin_as_checkoutperson = FactoryGirl.create(:admin, checkoutpersonmode: "1")
      admin_as_checkoutperson.is_admin_in_checkoutpersonmode?.should == true
    end
    it "should return false if the user is not an admin" do
      @user.save
      @user.is_admin_in_checkoutpersonmode?.should == false
    end
    it "should return false if user is admin in normalusermode" do
      admin_as_normal_user = FactoryGirl.create(:admin, normalusermode: "1")
      admin_as_normal_user.is_admin_in_checkoutpersonmode?.should == false
    end
    it "should return false if user is admin in bannedmode" do
      admin_as_banned = FactoryGirl.create(:admin, bannedmode: "1")
      admin_as_banned.is_admin_in_checkoutpersonmode?.should == false
    end
    it "should return false if user is admin in adminmode" do
      admin_as_admin = FactoryGirl.create(:admin, adminmode: "1")
      admin_as_admin.is_admin_in_checkoutpersonmode?.should == false
    end
  end

  describe ".is_admin_in_bannedmode?" do
    it "should return true if user is an admin in bannedmode" do
      admin_as_banned = FactoryGirl.create(:admin, bannedmode: "1")
      admin_as_banned.is_admin_in_bannedmode?.should == true
    end
    it "should return false if the user is not an admin" do
      @user.save
      @user.is_admin_in_bannedmode?.should == false
    end
    it "should return false if user is admin in normalusermode" do
      admin_as_normal_user = FactoryGirl.create(:admin, normalusermode: "1")
      admin_as_normal_user.is_admin_in_bannedmode?.should == false
    end
    it "should return false if user is admin in checkoutpersonmode" do
      admin_as_checkoutperson = FactoryGirl.create(:admin, checkoutpersonmode: "1")
      admin_as_checkoutperson.is_admin_in_bannedmode?.should == false
    end
    it "should return false if user is admin in adminmode" do
      admin_as_admin = FactoryGirl.create(:admin, adminmode: "1")
      admin_as_admin.is_admin_in_bannedmode?.should == false
    end
  end

  #TODO: write these tests once there are equipment_model, equipment_object, and reservation factories available
  describe ".equipment_objects"
  describe ".checked_out_models"

  #TODO: find a way to simulate an ldap database using a test fixture/factory of some kind
  describe "#search_ldap" do
    it "should return a hash of user attributes if the ldap database has the login associated with user"
    it "should return nil if the user is not in the ldap database"
  end

  # what does this method even do?
  describe "#select_options"

  describe ".render_name" do
    it "should return the nickname, last name, and login id as a string if nickname exists" do
      @user.render_name.should == "Sasha Fierce Knowles bgk1"
    end
    it "should return the first name, last name, and login id as a string if no nickname" do
      @no_nickname = FactoryGirl.create(:justin)
      @no_nickname.render_name.should == "Justin Timberlake jrt4"
    end
  end

  describe ".assign_type" do
    it "should set all types to nil except admin when passed 'admin' as type" do
      @user.assign_type('admin')
      @user.is_banned.should be_false
      @user.is_checkout_person.should be_false
      @user.is_admin.should be_true
    end
    it "should set all types to nil except checkout_person when passed 'checkout' as type" do
      @user.assign_type('checkout')
      @user.is_banned.should be_false
      @user.is_admin.should be_false
      @user.is_checkout_person.should be_true
    end
    it "should set all types to nil except is_banned when passed 'banned' as type" do
      @user.assign_type('banned')
      @user.is_admin.should be_false
      @user.is_checkout_person.should be_false
      @user.is_banned.should be_true
    end
    it "successfully removes old type when reassigning type from banned to admin" do
      @banned_to_admin = FactoryGirl.create(:user, is_banned: "1")
      @banned_to_admin.is_banned.should be_true
      @banned_to_admin.is_admin.should be_false
      @banned_to_admin.assign_type('admin')
      @banned_to_admin.is_admin.should be_true
      @banned_to_admin.is_banned.should be_false
    end
  end

end
