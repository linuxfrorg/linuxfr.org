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

require 'test_helper'

class VoteTest < ActiveSupport::TestCase

  def setup
    @node = Factory(:node)
    @user = Factory(:user, :login => 'joe')
  end

  test "A node has a score of 0 by default" do
    assert_equal 0, @node.score
  end

  test "A user can vote" do
    Vote.for(@user, @node)
    @node.reload
    assert_equal 1, @node.score
  end

  test "A user change its vote" do
    Vote.for(@user, @node)
    Vote.against(@user, @node)
    @node.reload
    assert_equal -1, @node.score
  end

  test "A user vote twice" do
    Vote.for(@user, @node)
    Vote.for(@user, @node)
    @node.reload
    assert_equal 1, @node.score
  end

  test "Two users can vote on the same node" do
    u = Factory(:user, :login => 'bob')
    Vote.for(u, @node)
    Vote.for(@user, @node)
    @node.reload
    assert_equal 2, @node.score
  end

end
