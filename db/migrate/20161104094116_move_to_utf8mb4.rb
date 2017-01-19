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
    execute "ALTER TABLE accounts DROP KEY index_accounts_on_email;"
    execute "ALTER TABLE accounts DROP KEY index_accounts_on_confirmation_token;"
    execute "ALTER TABLE accounts DROP KEY index_accounts_on_reset_password_token;"
    execute "ALTER TABLE tags DROP KEY index_tags_on_name;"

    execute "ALTER TABLE friendly_id_slugs MODIFY COLUMN slug VARCHAR(190);"
    execute "ALTER TABLE pages MODIFY COLUMN slug VARCHAR(128);"
    execute "ALTER TABLE accounts MODIFY COLUMN email VARCHAR(128) NOT NULL;"
    execute "ALTER TABLE accounts MODIFY COLUMN confirmation_token VARCHAR(64);"
    execute "ALTER TABLE accounts MODIFY COLUMN reset_password_token VARCHAR(64);"
    execute "ALTER TABLE nodes MODIFY COLUMN content_type VARCHAR(40);"

    TABLES.each do |tbl|
      execute "ALTER TABLE #{tbl} CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    end

    execute "ALTER TABLE friendly_id_slugs ADD KEY `index_friendly_id_slugs_on_slug_and_sluggable_type` (`slug`,`sluggable_type`) USING BTREE;"
    execute "ALTER TABLE nodes ADD UNIQUE KEY `index_nodes_on_content_id_and_content_type` (`content_id`,`content_type`) USING BTREE;"
    execute "ALTER TABLE nodes ADD KEY `index_nodes_on_content_type_and_public_and_interest` (`content_type`,`public`,`interest`) USING BTREE;"
    execute "ALTER TABLE pages ADD KEY `index_pages_on_slug` (`slug`) USING BTREE;"
    execute "ALTER TABLE accounts ADD UNIQUE KEY `index_accounts_on_email` (`email`) USING BTREE;"
    execute "ALTER TABLE accounts ADD UNIQUE KEY `index_accounts_on_confirmation_token` (`confirmation_token`) USING BTREE;"
    execute "ALTER TABLE accounts ADD UNIQUE KEY `index_accounts_on_reset_password_token` (`reset_password_token`) USING BTREE;"
    execute "ALTER TABLE tags ADD UNIQUE KEY `index_tags_on_name` (`name`) USING BTREE;"
  end

  def down
    execute "ALTER DATABASE #{db_name} CHARACTER SET = utf8 COLLATE = utf8_unicode_ci;"

    execute "ALTER TABLE friendly_id_slugs DROP KEY index_friendly_id_slugs_on_slug_and_sluggable_type;"
    execute "ALTER TABLE nodes DROP KEY index_nodes_on_content_id_and_content_type;"
    execute "ALTER TABLE nodes DROP KEY index_nodes_on_content_type_and_public_and_interest;"
    execute "ALTER TABLE pages DROP KEY index_pages_on_slug;"
    execute "ALTER TABLE accounts DROP KEY index_accounts_on_email;"
    execute "ALTER TABLE accounts DROP KEY index_accounts_on_confirmation_token;"
    execute "ALTER TABLE accounts DROP KEY index_accounts_on_reset_password_token;"
    execute "ALTER TABLE tags DROP KEY index_tags_on_name;"

    TABLES.each do |tbl|
      execute "ALTER TABLE #{tbl} CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    end

    execute "ALTER TABLE friendly_id_slugs MODIFY COLUMN slug VARCHAR(255);"
    execute "ALTER TABLE pages MODIFY COLUMN slug VARCHAR(255);"
    execute "ALTER TABLE accounts MODIFY COLUMN email VARCHAR(255);"
    execute "ALTER TABLE accounts MODIFY COLUMN confirmation_token VARCHAR(255);"
    execute "ALTER TABLE accounts MODIFY COLUMN reset_password_token VARCHAR(255);"
    execute "ALTER TABLE nodes MODIFY COLUMN content_type VARCHAR(255);"

    execute "ALTER TABLE friendly_id_slugs ADD KEY `index_friendly_id_slugs_on_slug_and_sluggable_type` (`slug`,`sluggable_type`) USING BTREE;"
    execute "ALTER TABLE nodes ADD UNIQUE KEY `index_nodes_on_content_id_and_content_type` (`content_id`,`content_type`) USING BTREE;"
    execute "ALTER TABLE nodes ADD KEY `index_nodes_on_content_type_and_public_and_interest` (`content_type`,`public`,`interest`) USING BTREE;"
    execute "ALTER TABLE pages ADD KEY `index_pages_on_slug` (`slug`) USING BTREE;"
    execute "ALTER TABLE accounts ADD UNIQUE KEY `index_accounts_on_email` (`email`) USING BTREE;"
    execute "ALTER TABLE accounts ADD UNIQUE KEY `index_accounts_on_confirmation_token` (`confirmation_token`) USING BTREE;"
    execute "ALTER TABLE accounts ADD UNIQUE KEY `index_accounts_on_reset_password_token` (`reset_password_token`) USING BTREE;"
    execute "ALTER TABLE tags ADD UNIQUE KEY `index_tags_on_name` (`name`) USING BTREE;"
  end

  def db_name
    Rails.configuration.database_configuration[Rails.env]['database']
  end
end
