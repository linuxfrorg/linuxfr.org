require 'test_helper'

class DiaryTest < ActiveSupport::TestCase
  test "user with positive karma can create diary" do
    diary = diaries(:lorem).dup;
    assert diary.creatable_by?(diary.owner.account);
    assert diary.save();
  end

  test "user with zero karma cannot create diary" do
    diary = diaries(:lorem).dup;
    diary.owner = users(:visitor_zero_karma);
    assert_not diary.creatable_by?(diary.owner.account);
    assert diary.save(), "Diary model were not saved";
  end

  test "user with negative karma cannot create diary" do
    diary = diaries(:lorem).dup;
    diary.owner = users(:visitor_negative_karma);
    assert_not diary.creatable_by?(diary.owner.account);
    assert diary.save(), "Diary model were not saved";
  end

  test "only admin and moderator can update a diary" do
    diary = diaries(:lorem);
    assert_not diary.updatable_by?(accounts(:visitor_1));
    assert_not diary.updatable_by?(accounts(:maintainer_1));
    assert diary.updatable_by?(accounts(:moderator_1));
    assert diary.updatable_by?(accounts(:admin_1));
  end

  test "only admin and moderator can destroy a diary" do
    diary = diaries(:lorem);
    assert_not diary.destroyable_by?(accounts(:visitor_1));
    assert_not diary.destroyable_by?(accounts(:maintainer_1));
    assert diary.destroyable_by?(accounts(:moderator_1));
    assert diary.destroyable_by?(accounts(:admin_1));
  end
end
