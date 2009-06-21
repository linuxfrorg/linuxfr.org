# == Schema Information
#
# Table name: readings
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)
#  node_id    :integer(4)
#  updated_at :datetime
#

class Reading < ActiveRecord::Base
  belongs_to :user
  belongs_to :node

  def self.update_for(node_id, user_id)
    stmt = "INSERT INTO readings(`user_id`, `node_id`, `updated_at`) VALUES (#{user_id}, #{node_id}, NOW()) ON DUPLICATE KEY UPDATE `updated_at`=NOW()"
    connection.insert_sql(stmt)
  end

end
