# encoding: utf-8
require 'spec_helper'

describe Api::V1::BoardController do
    describe 'POST #board' do
    let!(:account)     { Factory(:normal_account).reload }
    let!(:application) { Factory :application }
    let!(:token)       { Factory :access_token, application: application, resource_owner_id: account.id }
    let!(:message)     { "Un message très intéressant... ou pas" }

    it 'responds with 200' do
      post '/api/v1/board', access_token: token.token, message: message
      response.status.should eq(200)
    end

    it 'returns the id as json' do
      post '/api/v1/board', access_token: token.token, message: message
      response.body.should == { id: Board.last(Board.free).id }.to_json
    end

    it 'sets the attributes correctly' do
      post '/api/v1/board', access_token: token.token, message: message
      board = Board.last(Board.free)
      board.message.should == message
      board.user_agent.should == application.name
      board.user_name.should == account.user.name
      board.object_type.should == Board.free
    end
  end
end
