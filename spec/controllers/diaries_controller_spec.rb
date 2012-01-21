# encoding: utf-8
#
require 'spec_helper'

describe DiariesController do
  let(:diary) { FactoryGirl.create(:diary) }
  let(:owner) { diary.owner }

  it "shows the diary" do
    get :show, :user_id => owner.to_param, :id => diary.to_param
    response.should be_success
  end

  context "Deleted diary" do
    before(:each) { diary.mark_as_deleted }

    it "doesn't show the deleted diary" do
      get :show, :user_id => owner.to_param, :id => diary.to_param
      response.should contain("Accès interdit à cette page !")
    end
  end
end
