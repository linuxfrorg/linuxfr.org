# == Schema Information
# Schema version: 20090113223625
#
# Table name: sections
#
#  id         :integer(4)      not null, primary key
#  state      :string(255)
#  title      :string(255)     default("published"), not null
#  created_at :datetime
#  updated_at :datetime
#

class Section < ActiveRecord::Base
  has_many :news

  validates_presence_of :title, :message => "Le titre est obligatoire"

### Workflow ###

  include AASM
  aasm_column :state
  aasm_initial_state :published

  aasm_state :published
  aasm_state :deleted

  aasm_event :reopen do transitions :from => [:deleted], :to => :published end
  aasm_event :delete do transitions :from => [:published], :to => :deleted end

end
