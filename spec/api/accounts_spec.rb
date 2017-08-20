# encoding: utf-8
require 'spec_helper'

describe Api::V1::AccountsController do
    describe 'GET #me' do
    let!(:account)     { Factory(:normal_account).reload }
    let!(:application) { Factory :application }
    let!(:token)       { Factory :access_token, application: application, resource_owner_id: account.id }

    it 'responds with 200' do
      get '/api/v1/me', params: { access_token: token.token }
      response.status.should eq(200)
    end

    it 'returns the account as json' do
      get '/api/v1/me', params: { access_token: token.token }
      response.body.should == account.to_json
      JSON.parse(response.body).keys.should == %w(login email created_at)
    end
  end
end
