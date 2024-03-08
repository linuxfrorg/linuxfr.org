# encoding: utf-8
# == Schema Information
#
# Table name: diaries
#
#  id                :integer          not null, primary key
#  title             :string(160)      not null
#  cached_slug       :string(165)      not null
#  owner_id          :integer
#  body              :text(4294967295)
#  wiki_body         :text(16777215)
#  truncated_body    :text(16777215)
#  created_at        :datetime
#  updated_at        :datetime
#  converted_news_id :integer
#

# The users can post on theirs diaries.
# They can be used for sharing ideas,
# informations, discussions and trolls.
#
class Diary < Content
  self.table_name = "diaries"
  self.type = "Journal"

  belongs_to :owner, class_name: 'User'
  belongs_to :converted_news, class_name: 'News', optional: true

  validates :title,     presence: { message: "Le titre est obligatoire" },
                        length: { maximum: 100, message: "Le titre est trop long" }
  validates :wiki_body, presence: { message: "Vous ne pouvez pas poster un journal vide" }

  validate :convert_only_cc_licensed_diary, on: :convert

  wikify_attr   :body
  truncate_attr :body

  ### SEO ###

  extend FriendlyId
  friendly_id

  def should_generate_new_friendly_id?
    title_changed?
  end

  ### ACL ###

  def creatable_by?(account)
    account.karma > 0
  end

  def updatable_by?(account)
    account.moderator? || account.admin?
  end

  def destroyable_by?(account)
    account.moderator? || account.admin?
  end

  ### Moving ###
  def convert_only_cc_licensed_diary
    errors.add :base, :cannot_convert, message: "Le journal n’a pas été publié sous licence CC By-SA 4.0, il ne peut donc pas être proposé en dépêche." unless node.cc_licensed?
  end

  def convert
    validate!(:convert)
    @news = News.new title: title,
                     wiki_body: "**TODO** insérer une synthèse du journal",
                     wiki_second_part: wiki_body,
                     section_id: Section.default.id
    @news.author_name  = owner.try(:name)
    @news.author_email = owner.try(:account).try(:email)
    @news.transaction do
      @news.save!
      $redis.set "convert/#{@news.id}", self.id
      @news.node.update_column(:cc_licensed, node.cc_licensed)
      @news.links.create title: "Journal à l’origine de la dépêche", url: "https://#{MY_DOMAIN}/users/#{owner.to_param}/journaux/#{to_param}", lang: "fr"
      @news
    end
  end

  def move_to_forum(attrs)
    @post = Post.new(attrs)
    @post.title = title
    @post.wiki_body = wiki_body
    @post.transaction do
      @post.save!
      # The 2 nodes are swapped so that all references to the diairy
      # (comments, tags, etc.) are moved to the post.
      other = @post.node
      other.attributes = node.attributes.except("id", "content_id").merge(content_type: "XXX", public: false)
      other.save!(validate: false)
      Node.connection.update <<-SQL.squish
      UPDATE nodes
         SET content_id=(#{node.content_id + @post.node.content_id} - content_id),
             content_type=CASE content_type
                          WHEN 'Diary' THEN 'Post'
                          ELSE 'Diary' END
       WHERE id=#{node.id} OR id=#{@post.node.id}
      SQL
      node.compute_interest
    end
  end
end
