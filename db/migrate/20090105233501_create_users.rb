class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string   :name,        :limit => 32
      t.string   :homesite,    :limit => 100
      t.string   :jabber_id,   :limit => 32
      t.string   :cached_slug, :limit => 32

      # Avatar
      t.string   :avatar_file_name
      t.string   :avatar_content_type
      t.integer  :avatar_file_size
      t.datetime :avatar_updated_at

      t.timestamps
    end
    add_index :users, :cached_slug
  end

  def self.down
    drop_table :users
  end
end
