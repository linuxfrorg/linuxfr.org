require "test_helper"

# == Schema Information
#
# Table name: comments
#
#  id                :integer(4)      not null, primary key
#  node_id           :integer(4)
#  user_id           :integer(4)
#  state             :string(255)     default("published"), not null
#  title             :string(255)
#  body              :text
#  wiki_body         :text
#  score             :integer(4)      default(0)
#  answered_to_self  :boolean(1)      default(FALSE)
#  materialized_path :string(1022)
#  created_at        :datetime
#  updated_at        :datetime
#
class CommentTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
