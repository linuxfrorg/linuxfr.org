# == Schema Information
# Schema version: 20090120005239
#
# Table name: news
#
#  id          :integer(4)      not null, primary key
#  state       :string(255)     default("draft"), not null
#  title       :string(255)
#  body        :text
#  second_part :text
#  section_id  :integer(4)
#  created_at  :datetime
#  updated_at  :datetime
#

class News < Content
  belongs_to :section
  has_many :links

  validates_presence_of :title, :message => "Le titre est obligatoire"
  validates_presence_of :body,  :message => "Nous n'acceptons pas les dépêches vides"

### Workflow ###

  include AASM
  aasm_column :state
  aasm_initial_state :draft

  aasm_state :draft
  aasm_state :published
  aasm_state :refused
  aasm_state :deleted

  aasm_event :accept do transitions :from => [:draft],   :to => :published end
  aasm_event :refuse do transitions :from => [:draft],     :to => :refused end
  aasm_event :delete do transitions :from => [:published], :to => :deleted end

### Body ###

  def body
    b = body_before_type_cast
    b.blank? ? "" : WikiCreole.creole_parse(b)
  end

  def second_part
    b = second_part_before_type_cast
    b.blank? ? "" : WikiCreole.creole_parse(b)
  end

### ACL ###

  def readable_by?(user)
    state == 'published' || (user && user.amr?)
  end

  def creatable_by?(user)
    true
  end

  def editable_by?(user)
    user && user.amr?
  end

  def deletable_by?(user)
    user && (user.moderator? || user.admin?)
  end

end
