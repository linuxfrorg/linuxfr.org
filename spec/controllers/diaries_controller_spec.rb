require 'spec_helper'

describe DiariesController do
  before(:each) do
    User.delete_all
    Account.delete_all
    Node.delete_all
    Diary.delete_all
  end

  let(:diary) { Factory.create(:diary) }
  let(:owner) { diary.owner }

  it "shows the diary" do
    get :show, :user_id => owner.to_param, :id => diary.to_param
    response.should be_success
  end

  context "Deleted diary" do
    before(:each) { diary.mark_as_deleted }

    it "doesn't show the deleted diary" do
      expect do
        get :show, :user_id => owner.to_param, :id => diary.to_param
      end.to raise_error Canable::Transgression
    end
  end
end
