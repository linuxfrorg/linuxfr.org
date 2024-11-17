# encoding: UTF-8
# == Schema Information
#
# Table name: trackers
#
#  id                  :integer          not null, primary key
#  state               :string(10)       default("opened"), not null
#  title               :string(100)      not null
#  cached_slug         :string(105)      not null
#  category_id         :integer          not null
#  assigned_to_user_id :integer
#  body                :text(4294967295)
#  wiki_body           :text(16777215)
#  truncated_body      :text(16777215)
#  created_at          :datetime
#  updated_at          :datetime
#

#
# There are no bugs in LinuxFr.org, but if it would happen,
# the users can report them in the tracker.
# They can also suggest improvements here.
#
class Tracker < Content
  self.table_name = "trackers"
  self.type = "Suivi"

  belongs_to :assigned_to_user, class_name: "User", optional: true
  belongs_to :category

  attr_accessor :pot_de_miel

  validates :title,     presence: { message: "Le titre est obligatoire" },
                        length: { maximum: 100, message: "Le titre est trop long" }
  validates :wiki_body, presence: { message: "Veuillez décrire cette entrée du suivi" }

  scope :opened, -> { where(state: "opened") }

  wikify_attr   :body
  truncate_attr :body

### SEO ###

  extend FriendlyId
  friendly_id :title, reserved_words: %w(index nouveau modifier comments)

  def should_generate_new_friendly_id?
    title_changed?
  end

### Workflow ###

  States = { "opened" => "Ouverte", "fixed" => "Corrigée", "invalid" => "Invalide" }.freeze

  state_machine :state, initial: :opened do
    event :fix        do transition :opened => :fixed   end
    event :invalidate do transition :opened => :invalid end
    event :reopen     do transition all     => :opened  end
  end

### Presentation ###

  def state_name
    States[state].downcase
  end

  def category_title
    category.try(:title) || 'Suivi'
  end

  def assigned_to
    assigned_to_user.try(:name) || 'Personne'
  end

### ACL ###

  def updatable_by?(account)
    account.maintainer? || account.moderator? || account.admin? || account.user_id == node.user_id
  end

  def destroyable_by?(account)
    account.maintainer? || account.moderator? || account.admin?
  end

  def too_old_for_comments?
    false
  end

end
