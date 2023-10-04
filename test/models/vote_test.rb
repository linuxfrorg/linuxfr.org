require 'test_helper'

# == Schema Information
#
# Table name: votes
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)
#  node_id    :integer(4)
#  vote       :boolean(1)
#  created_at :datetime
#
class VoteTest < ActiveSupport::TestCase
  def setup
    @node = nodes(:diary_lorem_cc_licensed)
    @account = accounts(:joe)

    # Reset redis related data
    Redis.new.del "nodes/#{@node.id}/votes/#{@account.id}"
    Redis.new.del "nodes/#{@node.id}/votes/#{accounts(:bob).id}"
  end

  test 'A node has a score of 0 by default' do
    assert_equal 0, @node.score
  end

  test 'A user can vote' do
    assert_difference '@node.score' do
      @node.vote_for @account
      @node.reload
    end
  end

  test 'A user change its vote' do
    assert_difference '@node.score', -1 do
      @node.vote_for @account
      @node.vote_against @account
      @node.reload
    end
  end

  test 'A user vote twice' do
    assert_difference '@node.score' do
      @node.vote_for @account
      @node.reload
    end
  end

  test 'Two users can vote on the same node' do
    assert_difference '@node.score', 2 do
      @node.vote_for accounts(:bob)
      @node.vote_for @account
      @node.reload
    end
  end
end
