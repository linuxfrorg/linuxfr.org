class MoveToUtf8mb4 < ActiveRecord::Migration
  TABLES = [
     'accounts',
     'badges',
     'banners',
     'categories',
     'comments',
     'diaries',
     'forums',
     'friend_sites',
     'friendly_id_slugs',
     'links',
     'logs',
     'news',
     'news_versions',
     'nodes',
     'pages',
     'paragraphs',
     'poll_answers',
     'polls',
     'posts',
     'responses',
     'sections',
     'taggings',
     'tags',
     'trackers',
     'users',
     'wiki_pages',
     'wiki_versions',
  ]

  def up
    execute "ALTER DATABASE #{db_name} CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;"

    execute "ALTER TABLE friendly_id_slugs DROP KEY index_friendly_id_slugs_on_slug_and_sluggable_type;"

    execute "ALTER TABLE nodes DROP KEY index_nodes_on_content_id_and_content_type;"
    execute "ALTER TABLE nodes DROP KEY index_nodes_on_content_type_and_public_and_interest;"

    execute "ALTER TABLE pages DROP KEY index_pages_on_slug;"

    TABLES.each do |tbl|
      execute "ALTER TABLE #{tbl} CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    end

    execute "ALTER TABLE friendly_id_slugs ADD UNIQUE KEY `index_friendly_id_slugs_on_slug_and_sluggable_type` (`slug`(190),`sluggable_type`) USING BTREE;"

    execute "ALTER TABLE nodes ADD UNIQUE KEY `index_nodes_on_content_id_and_content_type` (`content_id`,`content_type`(190)) USING BTREE;"
    execute "ALTER TABLE nodes ADD KEY `index_nodes_on_content_type_and_public_and_interest` (`content_type`(190),`public`,`interest`) USING BTREE;"

    execute "ALTER TABLE pages ADD KEY `index_pages_on_slug` (`slug`(190)) USING BTREE;"
  end

  def down
    execute "ALTER DATABASE #{db_name} CHARACTER SET = utf8 COLLATE = utf8_unicode_ci;"

    execute "ALTER TABLE friendly_id_slugs DROP KEY index_friendly_id_slugs_on_slug_and_sluggable_type;"

    execute "ALTER TABLE nodes DROP KEY index_nodes_on_content_id_and_content_type;"
    execute "ALTER TABLE nodes DROP KEY index_nodes_on_content_type_and_public_and_interest;"

    execute "ALTER TABLE oauth_applications DROP KEY index_oauth_applications_on_owner_id_and_owner_type;"

    execute "ALTER TABLE pages DROP KEY index_pages_on_slug;"

    TABLES.each do |tbl|
      execute "ALTER TABLE #{tbl} CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    end

    execute "ALTER TABLE friendly_id_slugs ADD UNIQUE KEY `index_friendly_id_slugs_on_slug_and_sluggable_type` (`slug`,`sluggable_type`) USING BTREE;"

    execute "ALTER TABLE nodes ADD UNIQUE KEY `index_nodes_on_content_id_and_content_type` (`content_id`,`content_type`) USING BTREE;"
    execute "ALTER TABLE nodes ADD KEY `index_nodes_on_content_type_and_public_and_interest` (`content_type`,`public`,`interest`) USING BTREE;"

    execute "ALTER TABLE oauth_applications ADD KEY `index_oauth_applications_on_owner_id_and_owner_type` (`owner_id`,`owner_type`) USING BTREE;"

    execute "ALTER TABLE pages ADD KEY `index_pages_on_slug` (`slug`) USING BTREE;"
  end

  def db_name
    Rails.configuration.database_configuration[Rails.env]['database']
  end
end
