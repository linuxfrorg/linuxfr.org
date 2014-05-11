# encoding: utf-8
# == Schema Information
#
# Table name: diaries
#
#  id                :integer          not null, primary key
#  title             :string(160)      not null
#  cached_slug       :string(165)
#  owner_id          :integer
#  body              :text(16777215)
#  wiki_body         :text
#  truncated_body    :text
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
  belongs_to :converted_news, class_name: 'News'

  validates :title,     presence: { message: "Le titre est obligatoire" },
                        length: { maximum: 100, message: "Le titre est trop long" }
  validates :wiki_body, presence: { message: "Vous ne pouvez pas poster un journal vide" }

  wikify_attr   :body
  truncate_attr :body

### SEO ###

  extend FriendlyId
  friendly_id

  def should_generate_new_friendly_id?
    title_changed?
  end

### Search ####

  include Elasticsearch::Model

  scope :indexable, -> { joins(:node).where('nodes.public' => true) }

  mapping dynamic: false do
    indexes :created_at, type: 'date'
    indexes :username
    indexes :title,      analyzer: 'french'
    indexes :body,       analyzer: 'french'
    indexes :tags,       analyzer: 'keyword'
  end

  def as_indexed_json(options={})
    {
      id: self.id,
      created_at: created_at,
      username: owner.try(:name),
      title: title,
      body: body,
      tags: tag_names,
    }
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

  def convert
    @news = News.new title: title,
                     wiki_body: "**TODO** insérer une synthèse du journal",
                     wiki_second_part: wiki_body,
                     section_id: Section.default.id
    @news.author_name  = owner.try(:name)
    @news.author_email = owner.try(:account).try(:email)
    saved = @news.save
    if saved
      $redis.set "convert/#{@news.id}", self.id
      @news.node.update_column(:cc_licensed, true) if node.cc_licensed?
      @news.links.create title: "Journal à l'origine de la dépêche", url: "#{MY_DOMAIN}/users/#{owner.to_param}/journaux/#{to_param}", lang: "fr"
      @news.submit! unless node.cc_licensed?
      @news
    else
      nil
    end
  end

  def move_to_forum(attrs)
    @post = Post.new(attrs)
    @post.title = title
    @post.wiki_body = wiki_body
    saved = @post.save
    if saved
      # Note: the 2 nodes are swapped so that all references to the diairy
      # (comments, tags, etc.) are moved to the post.
      other = @post.node
      other.attributes = node.attributes.except("id").merge(content_type: "XXX", public: false)
      other.save
      node.update_column :content_type, "Post"
      node.update_column :content_id, @post.id
      other.content_type = "Diary"
      other.save
    end
    saved
  end

end
