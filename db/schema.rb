# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_10_01_132606) do
  create_table "accounts", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "user_id"
    t.string "login", limit: 40, null: false, collation: "utf8mb4_bin"
    t.string "role", limit: 10, default: "visitor", null: false
    t.integer "karma", default: 20, null: false
    t.integer "nb_votes", default: 0, null: false
    t.string "stylesheet"
    t.string "email", limit: 128, null: false
    t.string "encrypted_password", limit: 128, default: "", null: false
    t.string "confirmation_token", limit: 64
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "reset_password_token", limit: 64
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "preferences", default: 0, null: false
    t.datetime "reset_password_sent_at", precision: nil
    t.integer "min_karma", default: 20
    t.integer "max_karma", default: 20
    t.string "uploaded_stylesheet"
    t.date "last_seen_on"
    t.index ["confirmation_token"], name: "index_accounts_on_confirmation_token", unique: true
    t.index ["email"], name: "index_accounts_on_email", unique: true
    t.index ["login"], name: "index_accounts_on_login"
    t.index ["reset_password_token"], name: "index_accounts_on_reset_password_token", unique: true
    t.index ["role"], name: "index_accounts_on_role"
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "banners", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "title"
    t.text "content", size: :medium
    t.boolean "active", default: true
  end

  create_table "bookmarks", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "title", limit: 160, null: false
    t.string "cached_slug", limit: 165, null: false
    t.integer "owner_id"
    t.string "link", null: false
    t.string "lang", limit: 2, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["cached_slug"], name: "index_bookmarks_on_cached_slug"
    t.index ["owner_id"], name: "index_bookmarks_on_owner_id"
  end

  create_table "categories", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "title", limit: 32, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "comments", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "node_id", null: false
    t.integer "user_id"
    t.string "state", limit: 10, default: "published", null: false
    t.string "title", limit: 160, null: false
    t.integer "score", default: 0, null: false
    t.boolean "answered_to_self", default: false, null: false
    t.string "materialized_path", limit: 1022
    t.text "body", size: :long
    t.text "wiki_body", size: :medium
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["node_id"], name: "index_comments_on_node_id"
    t.index ["state", "created_at"], name: "index_comments_on_state_and_created_at"
    t.index ["state", "materialized_path"], name: "index_comments_on_state_and_materialized_path", length: { materialized_path: 120 }
    t.index ["user_id", "answered_to_self"], name: "index_comments_on_user_id_and_answered_to_self"
    t.index ["user_id", "state", "created_at"], name: "index_comments_on_user_id_and_state_and_created_at"
  end

  create_table "diaries", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "title", limit: 160, null: false
    t.string "cached_slug", limit: 165, null: false
    t.integer "owner_id"
    t.text "body", size: :long
    t.text "wiki_body", size: :medium
    t.text "truncated_body", size: :medium
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "converted_news_id"
    t.index ["cached_slug"], name: "index_diaries_on_cached_slug"
    t.index ["converted_news_id"], name: "fk_diaries_on_converted_news_id"
    t.index ["owner_id"], name: "index_diaries_on_owner_id"
  end

  create_table "forums", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "state", limit: 10, default: "active", null: false
    t.string "title", limit: 32, null: false
    t.string "cached_slug", limit: 32, null: false
    t.integer "position"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["cached_slug"], name: "index_forums_on_cached_slug"
  end

  create_table "friend_sites", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "title"
    t.string "url"
    t.integer "position"
    t.index ["position"], name: "index_friend_sites_on_position"
  end

  create_table "friendly_id_slugs", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "slug", limit: 190
    t.integer "sluggable_id"
    t.string "sluggable_type", limit: 40
    t.datetime "created_at", precision: nil
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "links", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "news_id", null: false
    t.string "title", limit: 100, null: false
    t.string "url", null: false
    t.string "lang", limit: 2, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["news_id"], name: "index_links_on_news_id"
  end

  create_table "logs", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "account_id", null: false
    t.string "description"
    t.datetime "created_at", precision: nil
    t.integer "user_id"
    t.index ["account_id"], name: "index_logs_on_account_id"
    t.index ["user_id"], name: "fk_logs_on_user_id"
  end

  create_table "news", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "state", limit: 10, default: "draft", null: false
    t.string "title", limit: 160, null: false
    t.string "cached_slug", limit: 165, null: false
    t.integer "moderator_id"
    t.integer "section_id", null: false
    t.string "author_name", limit: 32, null: false
    t.string "author_email", limit: 64, null: false
    t.text "body", size: :long
    t.text "second_part", size: :long
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.datetime "submitted_at", precision: nil
    t.index ["cached_slug"], name: "index_news_on_cached_slug"
    t.index ["moderator_id"], name: "fk_news_on_moderator_id"
    t.index ["section_id"], name: "index_news_on_section_id"
    t.index ["state"], name: "index_news_on_state"
  end

  create_table "news_versions", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "news_id", null: false
    t.integer "user_id"
    t.integer "version"
    t.string "title"
    t.text "body", size: :long
    t.text "second_part", size: :long
    t.text "links", size: :medium
    t.datetime "created_at", precision: nil
    t.index ["created_at"], name: "index_news_versions_on_created_at"
    t.index ["news_id", "user_id"], name: "index_news_versions_on_news_id_and_user_id"
    t.index ["news_id", "version"], name: "index_news_versions_on_news_id_and_version"
    t.index ["user_id", "created_at"], name: "index_news_versions_on_user_id_and_created_at"
  end

  create_table "nodes", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "content_id"
    t.string "content_type", limit: 40
    t.integer "user_id"
    t.boolean "public", default: true, null: false
    t.boolean "cc_licensed", default: true, null: false
    t.integer "score", default: 0, null: false
    t.integer "interest", default: 0, null: false
    t.integer "comments_count", default: 0, null: false
    t.datetime "last_commented_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["content_id", "content_type"], name: "index_nodes_on_content_id_and_content_type", unique: true
    t.index ["content_type", "public", "interest"], name: "index_nodes_on_content_type_and_public_and_interest"
    t.index ["public", "created_at"], name: "index_nodes_on_public_and_created_at"
    t.index ["public", "interest"], name: "index_nodes_on_public_and_interest"
    t.index ["public", "last_commented_at"], name: "index_nodes_on_public_and_last_commented_at"
    t.index ["public", "score"], name: "index_nodes_on_public_and_score"
    t.index ["user_id"], name: "index_nodes_on_user_id"
  end

  create_table "oauth_access_grants", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "resource_owner_id", null: false
    t.integer "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "revoked_at", precision: nil
    t.string "scopes"
    t.index ["application_id"], name: "fk_oauth_access_grants_on_application_id"
    t.index ["resource_owner_id"], name: "fk_oauth_access_grants_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "resource_owner_id"
    t.integer "application_id", null: false
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.string "scopes"
    t.index ["application_id"], name: "fk_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.integer "owner_id", null: false
    t.string "owner_type"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "scopes", default: "", null: false
    t.boolean "confidential", default: true, null: false
    t.index ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type"
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "pages", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "slug", limit: 128
    t.string "title"
    t.text "body", size: :medium
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["slug"], name: "index_pages_on_slug"
  end

  create_table "paragraphs", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "news_id", null: false
    t.integer "position"
    t.boolean "second_part"
    t.text "body", size: :medium
    t.text "wiki_body", size: :medium
    t.index ["news_id", "second_part", "position"], name: "index_paragraphs_on_news_id_and_more"
  end

  create_table "poll_answers", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "poll_id", null: false
    t.string "answer", limit: 128, null: false
    t.integer "votes", default: 0, null: false
    t.integer "position"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["poll_id", "position"], name: "index_poll_answers_on_poll_id_and_position"
  end

  create_table "polls", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "state", limit: 10, default: "draft", null: false
    t.string "title", limit: 128, null: false
    t.string "cached_slug", limit: 128, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.text "wiki_explanations", size: :medium
    t.text "explanations", size: :medium
    t.index ["cached_slug"], name: "index_polls_on_cached_slug"
    t.index ["state"], name: "index_polls_on_state"
  end

  create_table "posts", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "forum_id", null: false
    t.string "title", limit: 160, null: false
    t.string "cached_slug", limit: 165, null: false
    t.text "body", size: :long
    t.text "wiki_body", size: :medium
    t.text "truncated_body", size: :medium
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["cached_slug"], name: "index_posts_on_cached_slug"
    t.index ["forum_id"], name: "index_posts_on_forum_id"
  end

  create_table "responses", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "title", null: false
    t.text "content", size: :medium
  end

  create_table "sections", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "state", limit: 10, default: "published", null: false
    t.string "title", limit: 32, null: false
    t.string "cached_slug", limit: 32, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["cached_slug"], name: "index_sections_on_cached_slug"
    t.index ["state", "title"], name: "index_sections_on_state_and_title"
  end

  create_table "taggings", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "tag_id", null: false
    t.integer "node_id", null: false
    t.integer "user_id"
    t.datetime "created_at", precision: nil
    t.index ["created_at", "tag_id"], name: "index_taggings_on_created_at_and_tag_id"
    t.index ["node_id"], name: "index_taggings_on_node_id"
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["user_id"], name: "index_taggings_on_user_id"
  end

  create_table "tags", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.integer "taggings_count", default: 0, null: false
    t.boolean "public", default: true, null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
    t.index ["public", "taggings_count"], name: "index_tags_on_public_and_taggings_count"
  end

  create_table "trackers", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "state", limit: 10, default: "opened", null: false
    t.string "title", limit: 100, null: false
    t.string "cached_slug", limit: 105, null: false
    t.integer "category_id", null: false
    t.integer "assigned_to_user_id"
    t.text "body", size: :long
    t.text "wiki_body", size: :medium
    t.text "truncated_body", size: :medium
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["assigned_to_user_id"], name: "index_trackers_on_assigned_to_user_id"
    t.index ["cached_slug"], name: "index_trackers_on_cached_slug"
    t.index ["category_id"], name: "index_trackers_on_category_id"
    t.index ["state"], name: "index_trackers_on_state"
  end

  create_table "users", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", limit: 40
    t.string "homesite", limit: 100
    t.string "jabber_id", limit: 32
    t.string "cached_slug", limit: 32, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "avatar"
    t.string "signature"
    t.string "custom_avatar_url"
    t.string "mastodon_url"
    t.index ["cached_slug"], name: "index_users_on_cached_slug"
  end

  create_table "wiki_pages", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "title", limit: 100, null: false
    t.string "cached_slug", limit: 105, null: false
    t.text "body", size: :long
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.text "truncated_body"
    t.index ["cached_slug"], name: "index_wiki_pages_on_cached_slug"
  end

  create_table "wiki_versions", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "wiki_page_id", null: false
    t.integer "user_id"
    t.integer "version"
    t.string "message"
    t.text "body", size: :long
    t.datetime "created_at", precision: nil
    t.index ["user_id"], name: "fk_wiki_versions_on_user_id"
    t.index ["wiki_page_id", "version"], name: "index_wiki_versions_on_wiki_page_id_and_version"
  end

  add_foreign_key "accounts", "users", name: "fk_accounts_on_user_id"
  add_foreign_key "bookmarks", "users", column: "owner_id", name: "fk_bookmarks_on_owner_id"
  add_foreign_key "comments", "nodes", name: "fk_comments_on_node_id"
  add_foreign_key "comments", "users", name: "fk_comments_on_user_id"
  add_foreign_key "diaries", "news", column: "converted_news_id", name: "fk_diaries_on_converted_news_id"
  add_foreign_key "diaries", "users", column: "owner_id", name: "fk_diaries_on_owner_id"
  add_foreign_key "links", "news", name: "fk_links_on_news_id"
  add_foreign_key "logs", "accounts", name: "fk_logs_on_account_id"
  add_foreign_key "logs", "users", name: "fk_logs_on_user_id"
  add_foreign_key "news", "sections", name: "fk_news_on_section_id"
  add_foreign_key "news", "users", column: "moderator_id", name: "fk_news_on_moderator_id"
  add_foreign_key "news_versions", "news", name: "fk_news_versions_on_news_id"
  add_foreign_key "news_versions", "users", name: "fk_news_versions_on_user_id"
  add_foreign_key "nodes", "users", name: "fk_nodes_on_user_id"
  add_foreign_key "oauth_access_grants", "accounts", column: "resource_owner_id", name: "fk_oauth_access_grants_on_resource_owner_id"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id", name: "fk_oauth_access_grants_on_application_id"
  add_foreign_key "oauth_access_tokens", "accounts", column: "resource_owner_id", name: "fk_oauth_access_tokens_on_resource_owner_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id", name: "fk_oauth_access_tokens_on_application_id"
  add_foreign_key "oauth_applications", "accounts", column: "owner_id", name: "fk_oauth_applications_on_owner_id"
  add_foreign_key "paragraphs", "news", name: "fk_paragraphs_on_news_id"
  add_foreign_key "poll_answers", "polls", name: "fk_poll_answers_on_poll_id"
  add_foreign_key "posts", "forums", name: "fk_posts_on_forum_id"
  add_foreign_key "taggings", "nodes", name: "fk_taggings_on_node_id"
  add_foreign_key "taggings", "tags", name: "fk_taggings_on_tag_id"
  add_foreign_key "taggings", "users", name: "fk_taggings_on_user_id"
  add_foreign_key "trackers", "categories", name: "fk_trackers_on_category_id"
  add_foreign_key "trackers", "users", column: "assigned_to_user_id", name: "fk_trackers_on_assigned_to_user_id"
  add_foreign_key "wiki_versions", "users", name: "fk_wiki_versions_on_user_id"
  add_foreign_key "wiki_versions", "wiki_pages", name: "fk_wiki_versions_on_wiki_page_id"
end
