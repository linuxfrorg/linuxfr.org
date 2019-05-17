# encoding: utf-8
# == Schema Information
#
# Table name: tags
#
#  id             :integer          not null, primary key
#  name           :string(64)       not null
#  taggings_count :integer          default(0), not null
#  public         :boolean          default(TRUE), not null
#

class Tag < ActiveRecord::Base
  has_many :taggings, dependent: :destroy, inverse_of: :tag
  has_many :nodes, -> { distinct }, through: :taggings

  validates :name, presence: true, length: { maximum: 64, message: "Le tag est trop long" }

  attr_accessor :tagged_by_current

  scope :footer, -> {
    select([:name]).joins(:taggings).
                    where(public: true).
                    joins(:nodes).
                    where("nodes.public = 1").
                    where("taggings.created_at > ?", 1.month.ago).
                    group("taggings.tag_id").
                    order(Arel.sql("COUNT(*) DESC")).
                    limit(12)
  }
  scope :autocomplete, ->(q, nb) {
    where("name LIKE ?", "%#{q}%")
      .order(taggings_count: :desc)
      .limit(nb)
      .pluck(:name)
  }

### Near tags ###

  def near_tags
    Tag.find_by_sql <<-EOS
        SELECT t.name, COUNT(tg.id) AS cnt
          FROM tags t JOIN taggings tg ON t.id = tg.tag_id
         WHERE tg.node_id IN (SELECT DISTINCT node_id FROM taggings WHERE tag_id = #{self.id}) AND t.id != #{self.id}
      GROUP BY tg.tag_id ORDER BY cnt DESC LIMIT 10
    EOS
  end

### Visibility ###

  def updatable_by?(account)
    account.moderator? || account.admin?
  end

  def to_param
    name
  end

end
