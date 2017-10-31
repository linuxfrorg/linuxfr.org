# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171031210801) do

  create_table "accounts", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "user_id"
    t.string "login", limit: 40, null: false, collation: "utf8mb4_bin"
    t.string "role", limit: 10, default: "visitor", null: false
    t.integer "karma", default: 20, null: false
    t.integer "nb_votes", default: 0, null: false
    t.string "email", limit: 128, null: false
    t.string "encrypted_password", limit: 128, default: "", null: false
    t.string "confirmation_token", limit: 64
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "reset_password_token", limit: 64
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "preferences", default: 0, null: false
    t.datetime "reset_password_sent_at"
    t.integer "min_karma", default: 20
    t.integer "max_karma", default: 20
    t.index ["confirmation_token"], name: "index_accounts_on_confirmation_token", unique: true
    t.index ["email"], name: "index_accounts_on_email", unique: true
    t.index ["login"], name: "index_accounts_on_login"
    t.index ["reset_password_token"], name: "index_accounts_on_reset_password_token", unique: true
    t.index ["role"], name: "index_accounts_on_role"
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "badges", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "title"
    t.string "first_name"
    t.string "last_name"
    t.string "company"
    t.string "country"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "banners", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "title"
    t.text "content", limit: 4294967295
    t.boolean "active", default: true
  end

  create_table "categories", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "title", limit: 32, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "node_id"
    t.integer "user_id"
    t.string "state", limit: 10, default: "published", null: false
    t.string "title", limit: 160, null: false
    t.integer "score", default: 0, null: false
    t.boolean "answered_to_self", default: false, null: false
    t.string "materialized_path", limit: 1022
    t.text "body", limit: 4294967295
    t.text "wiki_body", limit: 4294967295
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["node_id"], name: "index_comments_on_node_id"
    t.index ["state", "created_at"], name: "index_comments_on_state_and_created_at"
    t.index ["state", "materialized_path"], name: "index_comments_on_state_and_materialized_path", length: { materialized_path: 120 }
    t.index ["user_id", "answered_to_self"], name: "index_comments_on_user_id_and_answered_to_self"
    t.index ["user_id", "state", "created_at"], name: "index_comments_on_user_id_and_state_and_created_at"
  end

  create_table "diaries", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "title", limit: 160, null: false
    t.string "cached_slug", limit: 165, collation: "utf8mb4_bin"
    t.integer "owner_id"
    t.text "body", limit: 4294967295
    t.text "wiki_body", limit: 4294967295
    t.text "truncated_body", limit: 4294967295
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "converted_news_id"
    t.index ["cached_slug"], name: "index_diaries_on_cached_slug"
    t.index ["owner_id"], name: "index_diaries_on_owner_id"
  end

  create_table "forums", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "state", limit: 10, default: "active", null: false
    t.string "title", limit: 32, null: false
    t.string "cached_slug", limit: 32
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["cached_slug"], name: "index_forums_on_cached_slug"
  end

  create_table "friend_sites", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "title"
    t.string "url"
    t.integer "position"
    t.index ["position"], name: "index_friend_sites_on_position"
  end

  create_table "friendly_id_slugs", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "slug", limit: 190
    t.integer "sluggable_id"
    t.string "sluggable_type", limit: 40
    t.datetime "created_at"
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "links", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "news_id", null: false
    t.string "title", limit: 100, null: false
    t.string "url", null: false
    t.string "lang", limit: 2, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["news_id"], name: "index_links_on_news_id"
  end

  create_table "logs", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "account_id"
    t.string "description"
    t.datetime "created_at"
    t.integer "user_id"
    t.index ["account_id"], name: "index_logs_on_account_id"
  end

  create_table "news", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "state", limit: 10, default: "draft", null: false
    t.string "title", limit: 160, null: false
    t.string "cached_slug", limit: 165, collation: "utf8mb4_bin"
    t.integer "moderator_id"
    t.integer "section_id"
    t.string "author_name", limit: 32, null: false
    t.string "author_email", limit: 64, null: false
    t.text "body", limit: 4294967295
    t.text "second_part", limit: 4294967295
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "submitted_at"
    t.index ["cached_slug"], name: "index_news_on_cached_slug"
    t.index ["section_id"], name: "index_news_on_section_id"
    t.index ["state"], name: "index_news_on_state"
  end

  create_table "news_versions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "news_id"
    t.integer "user_id"
    t.integer "version"
    t.string "title"
    t.text "body", limit: 4294967295
    t.text "second_part", limit: 4294967295
    t.text "links", limit: 4294967295
    t.datetime "created_at"
    t.index ["created_at"], name: "index_news_versions_on_created_at"
    t.index ["news_id", "user_id"], name: "index_news_versions_on_news_id_and_user_id"
    t.index ["news_id", "version"], name: "index_news_versions_on_news_id_and_version"
    t.index ["user_id", "created_at"], name: "index_news_versions_on_user_id_and_created_at"
  end

  create_table "nodes", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "content_id"
    t.string "content_type", limit: 40
    t.integer "user_id"
    t.boolean "public", default: true, null: false
    t.boolean "cc_licensed", default: true, null: false
    t.integer "score", default: 0, null: false
    t.integer "interest", default: 0, null: false
    t.integer "comments_count", default: 0, null: false
    t.datetime "last_commented_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["content_id", "content_type"], name: "index_nodes_on_content_id_and_content_type", unique: true
    t.index ["content_type", "public", "interest"], name: "index_nodes_on_content_type_and_public_and_interest"
    t.index ["public", "created_at"], name: "index_nodes_on_public_and_created_at"
    t.index ["public", "interest"], name: "index_nodes_on_public_and_interest"
    t.index ["public", "last_commented_at"], name: "index_nodes_on_public_and_last_commented_at"
    t.index ["public", "score"], name: "index_nodes_on_public_and_score"
    t.index ["user_id"], name: "index_nodes_on_user_id"
  end

  create_table "oauth_access_grants", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "resource_owner_id", null: false
    t.integer "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "resource_owner_id"
    t.integer "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.integer "owner_id"
    t.string "owner_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "scopes", default: "", null: false
    t.index ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type"
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "pages", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "slug", limit: 128
    t.string "title"
    t.text "body", limit: 4294967295
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["slug"], name: "index_pages_on_slug"
  end

  create_table "paragraphs", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "news_id", null: false
    t.integer "position"
    t.boolean "second_part"
    t.text "body", limit: 4294967295
    t.text "wiki_body", limit: 4294967295
    t.index ["news_id", "second_part", "position"], name: "index_paragraphs_on_news_id_and_more"
  end

  create_table "poll_answers", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "poll_id"
    t.string "answer", limit: 128, null: false
    t.integer "votes", default: 0, null: false
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["poll_id", "position"], name: "index_poll_answers_on_poll_id_and_position"
  end

  create_table "polls", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "state", limit: 10, default: "draft", null: false
    t.string "title", limit: 128, null: false
    t.string "cached_slug", limit: 128
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "wiki_explanations", limit: 4294967295
    t.text "explanations", limit: 4294967295
    t.index ["cached_slug"], name: "index_polls_on_cached_slug"
    t.index ["state"], name: "index_polls_on_state"
  end

  create_table "posts", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "forum_id"
    t.string "title", limit: 160, null: false
    t.string "cached_slug", limit: 165, collation: "utf8mb4_bin"
    t.text "body", limit: 4294967295
    t.text "wiki_body", limit: 4294967295
    t.text "truncated_body", limit: 4294967295
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["cached_slug"], name: "index_posts_on_cached_slug"
    t.index ["forum_id"], name: "index_posts_on_forum_id"
  end

  create_table "responses", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "title", null: false
    t.text "content", limit: 4294967295
  end

  create_table "sections", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "state", limit: 10, default: "published", null: false
    t.string "title", limit: 32, null: false
    t.string "cached_slug", limit: 32
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["cached_slug"], name: "index_sections_on_cached_slug"
    t.index ["state", "title"], name: "index_sections_on_state_and_title"
  end

  create_table "taggings", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "tag_id"
    t.integer "node_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.index ["created_at", "tag_id"], name: "index_taggings_on_created_at_and_tag_id"
    t.index ["node_id"], name: "index_taggings_on_node_id"
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["user_id"], name: "index_taggings_on_user_id"
  end

  create_table "tags", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "name", limit: 64, null: false
    t.integer "taggings_count", default: 0, null: false
    t.boolean "public", default: true, null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
    t.index ["public", "taggings_count"], name: "index_tags_on_public_and_taggings_count"
  end

  create_table "trackers", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "state", limit: 10, default: "opened", null: false
    t.string "title", limit: 100, null: false
    t.string "cached_slug", limit: 105
    t.integer "category_id"
    t.integer "assigned_to_user_id"
    t.text "body", limit: 4294967295
    t.text "wiki_body", limit: 4294967295
    t.text "truncated_body", limit: 4294967295
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["assigned_to_user_id"], name: "index_trackers_on_assigned_to_user_id"
    t.index ["cached_slug"], name: "index_trackers_on_cached_slug"
    t.index ["category_id"], name: "index_trackers_on_category_id"
    t.index ["state"], name: "index_trackers_on_state"
  end

  create_table "users", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "name", limit: 32
    t.string "homesite", limit: 100
    t.string "jabber_id", limit: 32
    t.string "cached_slug", limit: 32
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "avatar"
    t.string "signature"
    t.string "custom_avatar_url"
    t.index ["cached_slug"], name: "index_users_on_cached_slug"
  end

  create_table "wiki_pages", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "title", limit: 100, null: false
    t.string "cached_slug", limit: 105
    t.text "body", limit: 4294967295
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "truncated_body"
    t.index ["cached_slug"], name: "index_wiki_pages_on_cached_slug"
  end

  create_table "wiki_versions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "wiki_page_id"
    t.integer "user_id"
    t.integer "version"
    t.string "message"
    t.text "body", limit: 4294967295
    t.datetime "created_at"
    t.index ["wiki_page_id", "version"], name: "index_wiki_versions_on_wiki_page_id_and_version"
  end

end
