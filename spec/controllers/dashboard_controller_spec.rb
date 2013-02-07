require 'spec_helper'

describe DashboardController do

  describe "logged in" do

    before(:each) do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    it "renders index page" do
      get :index
      response.should be_success
    end

    it "renders api docs page" do
      get :api
      response.should be_success
    end

    it "renders api key page" do
      get :key
      response.should be_success
    end

  end

end
