require "test_helper"

# == Schema Information
#
# Table name: nodes
#
#  id                :integer(4)      not null, primary key
#  content_id        :integer(4)
#  content_type      :string(255)
#  score             :integer(4)      default(0)
#  interest          :integer(4)      default(0)
#  user_id           :integer(4)
#  public            :boolean(1)      default(TRUE)
#  cc_licensed       :boolean(1)      default(FALSE)
#  comments_count    :integer(4)      default(0)
#  last_commented_at :datetime
#  created_at        :datetime
#  updated_at        :datetime
#
class NodeTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
