require 'test_helper'

class LangTest < ActiveSupport::TestCase
  setup do
    Redis.new.del 'lang'
    Redis.new.del 'lang/fr'
  end

  test 'should have no language' do
    assert_empty Lang.all
  end

  test 'should add one language' do
    Lang['fr'] = 'Français'

    assert_not_empty Lang.all
    assert_equal 1, Lang.all.size
  end
end
