# encoding: utf-8
require 'test_helper'

class DiaryTest < ActiveSupport::TestCase
  test "user with positive karma can create diary" do
    diary = diaries(:lorem_cc_licensed).dup;
    assert diary.creatable_by?(diary.owner.account);
    assert diary.save();
  end

  test "user with zero karma cannot create diary" do
    diary = diaries(:lorem_cc_licensed).dup;
    diary.owner = users(:visitor_zero_karma);
    assert_not diary.creatable_by?(diary.owner.account);
    assert diary.save(), "Diary model were not saved";
  end

  test "user with negative karma cannot create diary" do
    diary = diaries(:lorem_cc_licensed).dup;
    diary.owner = users(:visitor_negative_karma);
    assert_not diary.creatable_by?(diary.owner.account);
    assert diary.save(), "Diary model were not saved";
  end

  test "only admin and moderator can update a diary" do
    diary = diaries(:lorem_cc_licensed);
    assert_not diary.updatable_by?(accounts(:visitor_1));
    assert_not diary.updatable_by?(accounts(:maintainer_1));
    assert diary.updatable_by?(accounts(:moderator_1));
    assert diary.updatable_by?(accounts(:admin_1));
  end

  test "only admin and moderator can destroy a diary" do
    diary = diaries(:lorem_cc_licensed);
    assert_not diary.destroyable_by?(accounts(:visitor_1));
    assert_not diary.destroyable_by?(accounts(:maintainer_1));
    assert diary.destroyable_by?(accounts(:moderator_1));
    assert diary.destroyable_by?(accounts(:admin_1));
  end

  test "convert cc_licensed diary to news in redaction space" do
    diary = diaries(:lorem_cc_licensed);
    diary.node = nodes(:diary_lorem_cc_licensed);
    created_news = diary.convert();
    # Retrieve News from database to ensure it were saved correctly
    news = News.find(created_news.id);
    # Ensure convert work
    assert_equal diary.title, news.title;
    assert_equal "**TODO** insérer une synthèse du journal", news.versions.first().body;
    assert_equal diary.wiki_body, news.versions.first().second_part;
    assert_equal diary.owner.try(:name), news.author_name;
    assert_equal diary.owner.try(:account).try(:email), news.author_email;
    assert_equal diary.node.cc_licensed, news.node.cc_licensed;
    assert news.node.cc_licensed;
    assert_equal sections(:default).id, news.section_id;
    # As diary is cc_licensed, news can be reworked collectively in the redaction space
    assert_equal "draft", news.state;
  end

  test "convert copyrighted diary to news in moderation space" do
    diary = diaries(:lorem_copyright);
    diary.node = nodes(:diary_lorem_copyright);
    created_news = diary.convert();
    # Retrieve News from database to ensure it were saved correctly
    news = News.find(created_news.id);
    # Ensure convert work
    assert_equal diary.title, news.title;
    assert_equal "**TODO** insérer une synthèse du journal", news.versions.first().body;
    assert_equal diary.wiki_body, news.versions.first().second_part;
    assert_equal diary.owner.try(:name), news.author_name;
    assert_equal diary.owner.try(:account).try(:email), news.author_email;
    # Even if original diary were copyrighted, the created news is cc_licensed
    assert_not_equal diary.node.cc_licensed, news.node.cc_licensed;
    assert news.node.cc_licensed;
    assert_equal sections(:default).id, news.section_id;
    # As diary is not cc_licensed, news cannot be reworked collectively in the redaction space
    assert_equal "candidate", news.state;
  end
end
