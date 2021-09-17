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
end
