# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150408104037) do

  create_table "accounts", force: :cascade do |t|
    t.integer  "user_id",                limit: 4
    t.string   "login",                  limit: 40,                      null: false
    t.string   "role",                   limit: 10,  default: "visitor", null: false
    t.integer  "karma",                  limit: 4,   default: 20,        null: false
    t.integer  "nb_votes",               limit: 4,   default: 0,         null: false
    t.string   "stylesheet",             limit: 255
    t.string   "email",                  limit: 255, default: "",        null: false
    t.string   "encrypted_password",     limit: 128, default: "",        null: false
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "reset_password_token",   limit: 255
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "preferences",            limit: 4,   default: 0,         null: false
    t.datetime "reset_password_sent_at"
    t.integer  "min_karma",              limit: 4,   default: 20
    t.integer  "max_karma",              limit: 4,   default: 20
    t.string   "uploaded_stylesheet",    limit: 255
  end

  add_index "accounts", ["confirmation_token"], name: "index_accounts_on_confirmation_token", unique: true, using: :btree
  add_index "accounts", ["email"], name: "index_accounts_on_email", unique: true, using: :btree
  add_index "accounts", ["login"], name: "index_accounts_on_login", using: :btree
  add_index "accounts", ["reset_password_token"], name: "index_accounts_on_reset_password_token", unique: true, using: :btree
  add_index "accounts", ["role"], name: "index_accounts_on_role", using: :btree
  add_index "accounts", ["user_id"], name: "index_accounts_on_user_id", using: :btree

  create_table "badges", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.string   "first_name", limit: 255
    t.string   "last_name",  limit: 255
    t.string   "company",    limit: 255
    t.string   "country",    limit: 255
    t.string   "email",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "banners", force: :cascade do |t|
    t.string  "title",   limit: 255
    t.text    "content", limit: 65535
    t.boolean "active",  limit: 1,     default: true
  end

  create_table "categories", force: :cascade do |t|
    t.string   "title",      limit: 32, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", force: :cascade do |t|
    t.integer  "node_id",           limit: 4
    t.integer  "user_id",           limit: 4
    t.string   "state",             limit: 10,       default: "published", null: false
    t.string   "title",             limit: 160,                            null: false
    t.integer  "score",             limit: 4,        default: 0,           null: false
    t.boolean  "answered_to_self",  limit: 1,        default: false,       null: false
    t.string   "materialized_path", limit: 1022
    t.text     "body",              limit: 16777215
    t.text     "wiki_body",         limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["node_id"], name: "index_comments_on_node_id", using: :btree
  add_index "comments", ["state", "created_at"], name: "index_comments_on_state_and_created_at", using: :btree
  add_index "comments", ["state", "materialized_path"], name: "index_comments_on_state_and_materialized_path", length: {"state"=>nil, "materialized_path"=>120}, using: :btree
  add_index "comments", ["user_id", "answered_to_self"], name: "index_comments_on_user_id_and_answered_to_self", using: :btree
  add_index "comments", ["user_id", "state", "created_at"], name: "index_comments_on_user_id_and_state_and_created_at", using: :btree

  create_table "diaries", force: :cascade do |t|
    t.string   "title",             limit: 160,      null: false
    t.string   "cached_slug",       limit: 165
    t.integer  "owner_id",          limit: 4
    t.text     "body",              limit: 16777215
    t.text     "wiki_body",         limit: 65535
    t.text     "truncated_body",    limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "converted_news_id", limit: 4
  end

  add_index "diaries", ["cached_slug"], name: "index_diaries_on_cached_slug", using: :btree
  add_index "diaries", ["owner_id"], name: "index_diaries_on_owner_id", using: :btree

  create_table "forums", force: :cascade do |t|
    t.string   "state",       limit: 10, default: "active", null: false
    t.string   "title",       limit: 32,                    null: false
    t.string   "cached_slug", limit: 32
    t.integer  "position",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "forums", ["cached_slug"], name: "index_forums_on_cached_slug", using: :btree

  create_table "friend_sites", force: :cascade do |t|
    t.string  "title",    limit: 255
    t.string  "url",      limit: 255
    t.integer "position", limit: 4
  end

  add_index "friend_sites", ["position"], name: "index_friend_sites_on_position", using: :btree

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",           limit: 255
    t.integer  "sluggable_id",   limit: 4
    t.string   "sluggable_type", limit: 40
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", unique: true, using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "links", force: :cascade do |t|
    t.integer  "news_id",    limit: 4,   null: false
    t.string   "title",      limit: 100, null: false
    t.string   "url",        limit: 255, null: false
    t.string   "lang",       limit: 2,   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "links", ["news_id"], name: "index_links_on_news_id", using: :btree

  create_table "logs", force: :cascade do |t|
    t.integer  "account_id",  limit: 4
    t.string   "description", limit: 255
    t.datetime "created_at"
    t.integer  "user_id",     limit: 4
  end

  add_index "logs", ["account_id"], name: "index_logs_on_account_id", using: :btree

  create_table "news", force: :cascade do |t|
    t.string   "state",        limit: 10,         default: "draft", null: false
    t.string   "title",        limit: 160,                          null: false
    t.string   "cached_slug",  limit: 165
    t.integer  "moderator_id", limit: 4
    t.integer  "section_id",   limit: 4
    t.string   "author_name",  limit: 32,                           null: false
    t.string   "author_email", limit: 64,                           null: false
    t.text     "body",         limit: 16777215
    t.text     "second_part",  limit: 4294967295
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "submitted_at"
  end

  add_index "news", ["cached_slug"], name: "index_news_on_cached_slug", using: :btree
  add_index "news", ["section_id"], name: "index_news_on_section_id", using: :btree
  add_index "news", ["state"], name: "index_news_on_state", using: :btree

  create_table "news_versions", force: :cascade do |t|
    t.integer  "news_id",     limit: 4
    t.integer  "user_id",     limit: 4
    t.integer  "version",     limit: 4
    t.string   "title",       limit: 255
    t.text     "body",        limit: 16777215
    t.text     "second_part", limit: 16777215
    t.text     "links",       limit: 65535
    t.datetime "created_at"
  end

  add_index "news_versions", ["created_at"], name: "index_news_versions_on_created_at", using: :btree
  add_index "news_versions", ["news_id", "version"], name: "index_news_versions_on_news_id_and_version", using: :btree
  add_index "news_versions", ["user_id", "created_at"], name: "index_news_versions_on_user_id_and_created_at", using: :btree

  create_table "nodes", force: :cascade do |t|
    t.integer  "content_id",        limit: 4
    t.string   "content_type",      limit: 255
    t.integer  "user_id",           limit: 4
    t.boolean  "public",            limit: 1,   default: true, null: false
    t.boolean  "cc_licensed",       limit: 1,   default: true, null: false
    t.integer  "score",             limit: 4,   default: 0,    null: false
    t.integer  "interest",          limit: 4,   default: 0,    null: false
    t.integer  "comments_count",    limit: 4,   default: 0,    null: false
    t.datetime "last_commented_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "nodes", ["content_id", "content_type"], name: "index_nodes_on_content_id_and_content_type", unique: true, using: :btree
  add_index "nodes", ["content_type", "public", "interest"], name: "index_nodes_on_content_type_and_public_and_interest", using: :btree
  add_index "nodes", ["public", "created_at"], name: "index_nodes_on_public_and_created_at", using: :btree
  add_index "nodes", ["public", "interest"], name: "index_nodes_on_public_and_interest", using: :btree
  add_index "nodes", ["public", "last_commented_at"], name: "index_nodes_on_public_and_last_commented_at", using: :btree
  add_index "nodes", ["public", "score"], name: "index_nodes_on_public_and_score", using: :btree
  add_index "nodes", ["user_id"], name: "index_nodes_on_user_id", using: :btree

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer  "resource_owner_id", limit: 4,     null: false
    t.integer  "application_id",    limit: 4,     null: false
    t.string   "token",             limit: 255,   null: false
    t.integer  "expires_in",        limit: 4,     null: false
    t.text     "redirect_uri",      limit: 65535, null: false
    t.datetime "created_at",                      null: false
    t.datetime "revoked_at"
    t.string   "scopes",            limit: 255
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer  "resource_owner_id", limit: 4
    t.integer  "application_id",    limit: 4
    t.string   "token",             limit: 255, null: false
    t.string   "refresh_token",     limit: 255
    t.integer  "expires_in",        limit: 4
    t.datetime "revoked_at"
    t.datetime "created_at",                    null: false
    t.string   "scopes",            limit: 255
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", force: :cascade do |t|
    t.string   "name",         limit: 255,                null: false
    t.string   "uid",          limit: 255,                null: false
    t.string   "secret",       limit: 255,                null: false
    t.text     "redirect_uri", limit: 65535,              null: false
    t.integer  "owner_id",     limit: 4
    t.string   "owner_type",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "scopes",       limit: 255,   default: "", null: false
  end

  add_index "oauth_applications", ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type", using: :btree
  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "pages", force: :cascade do |t|
    t.string   "slug",       limit: 255
    t.string   "title",      limit: 255
    t.text     "body",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pages", ["slug"], name: "index_pages_on_slug", using: :btree

  create_table "paragraphs", force: :cascade do |t|
    t.integer "news_id",     limit: 4,     null: false
    t.integer "position",    limit: 4
    t.boolean "second_part", limit: 1
    t.text    "body",        limit: 65535
    t.text    "wiki_body",   limit: 65535
  end

  add_index "paragraphs", ["news_id", "second_part", "position"], name: "index_paragraphs_on_news_id_and_more", using: :btree

  create_table "poll_answers", force: :cascade do |t|
    t.integer  "poll_id",    limit: 4
    t.string   "answer",     limit: 128,             null: false
    t.integer  "votes",      limit: 4,   default: 0, null: false
    t.integer  "position",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "poll_answers", ["poll_id", "position"], name: "index_poll_answers_on_poll_id_and_position", using: :btree

  create_table "polls", force: :cascade do |t|
    t.string   "state",             limit: 10,    default: "draft", null: false
    t.string   "title",             limit: 128,                     null: false
    t.string   "cached_slug",       limit: 128
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "wiki_explanations", limit: 65535
    t.text     "explanations",      limit: 65535
  end

  add_index "polls", ["cached_slug"], name: "index_polls_on_cached_slug", using: :btree
  add_index "polls", ["state"], name: "index_polls_on_state", using: :btree

  create_table "posts", force: :cascade do |t|
    t.integer  "forum_id",       limit: 4
    t.string   "title",          limit: 160,      null: false
    t.string   "cached_slug",    limit: 165
    t.text     "body",           limit: 16777215
    t.text     "wiki_body",      limit: 65535
    t.text     "truncated_body", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "posts", ["cached_slug"], name: "index_posts_on_cached_slug", using: :btree
  add_index "posts", ["forum_id"], name: "index_posts_on_forum_id", using: :btree

  create_table "responses", force: :cascade do |t|
    t.string "title",   limit: 255,   null: false
    t.text   "content", limit: 65535
  end

  create_table "sections", force: :cascade do |t|
    t.string   "state",       limit: 10, default: "published", null: false
    t.string   "title",       limit: 32,                       null: false
    t.string   "cached_slug", limit: 32
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sections", ["cached_slug"], name: "index_sections_on_cached_slug", using: :btree
  add_index "sections", ["state", "title"], name: "index_sections_on_state_and_title", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id",     limit: 4
    t.integer  "node_id",    limit: 4
    t.integer  "user_id",    limit: 4
    t.datetime "created_at"
  end

  add_index "taggings", ["created_at", "tag_id"], name: "index_taggings_on_created_at_and_tag_id", using: :btree
  add_index "taggings", ["node_id"], name: "index_taggings_on_node_id", using: :btree
  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
  add_index "taggings", ["user_id"], name: "index_taggings_on_user_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",           limit: 64,                null: false
    t.integer "taggings_count", limit: 4,  default: 0,    null: false
    t.boolean "public",         limit: 1,  default: true, null: false
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree
  add_index "tags", ["public", "taggings_count"], name: "index_tags_on_public_and_taggings_count", using: :btree

  create_table "trackers", force: :cascade do |t|
    t.string   "state",               limit: 10,       default: "opened", null: false
    t.string   "title",               limit: 100,                         null: false
    t.string   "cached_slug",         limit: 105
    t.integer  "category_id",         limit: 4
    t.integer  "assigned_to_user_id", limit: 4
    t.text     "body",                limit: 16777215
    t.text     "wiki_body",           limit: 65535
    t.text     "truncated_body",      limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "trackers", ["assigned_to_user_id"], name: "index_trackers_on_assigned_to_user_id", using: :btree
  add_index "trackers", ["cached_slug"], name: "index_trackers_on_cached_slug", using: :btree
  add_index "trackers", ["category_id"], name: "index_trackers_on_category_id", using: :btree
  add_index "trackers", ["state"], name: "index_trackers_on_state", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name",              limit: 32
    t.string   "homesite",          limit: 100
    t.string   "jabber_id",         limit: 32
    t.string   "cached_slug",       limit: 32
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar",            limit: 255
    t.string   "signature",         limit: 255
    t.string   "custom_avatar_url", limit: 255
  end

  add_index "users", ["cached_slug"], name: "index_users_on_cached_slug", using: :btree

  create_table "wiki_pages", force: :cascade do |t|
    t.string   "title",       limit: 100,      null: false
    t.string   "cached_slug", limit: 105
    t.text     "body",        limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "wiki_pages", ["cached_slug"], name: "index_wiki_pages_on_cached_slug", using: :btree

  create_table "wiki_versions", force: :cascade do |t|
    t.integer  "wiki_page_id", limit: 4
    t.integer  "user_id",      limit: 4
    t.integer  "version",      limit: 4
    t.string   "message",      limit: 255
    t.text     "body",         limit: 16777215
    t.datetime "created_at"
  end

  add_index "wiki_versions", ["wiki_page_id", "version"], name: "index_wiki_versions_on_wiki_page_id_and_version", using: :btree

end
