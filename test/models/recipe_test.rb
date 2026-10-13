require 'test_helper'

class RecipeTest < ActiveSupport::TestCase
  # Builds an unsaved favorite with a 40-day expected interval:
  # lifetime = 480 days over 13 cooks -> 480 / 12 = 40.
  def favorite_last_cooked(days_ago:, interval: 40, cooks: 13)
    lifetime = interval * (cooks - 1)
    Recipe.new(
      name: 'Test',
      cooks_count: cooks,
      last_cooked_on: Time.zone.today - days_ago,
      created_at: (Time.zone.today - days_ago - lifetime).to_time
    )
  end

  test 'forgotten when overdue within the window' do
    assert favorite_last_cooked(days_ago: 130).forgotten? # 3.25x interval
  end

  test 'not forgotten before 2.5x expected interval' do
    assert_not favorite_last_cooked(days_ago: 90).forgotten? # 2.25x interval
  end

  test 'ages out past 6x expected interval' do
    assert_not favorite_last_cooked(days_ago: 250).forgotten? # 6.25x interval
  end

  test 'not forgotten under the 45 day floor' do
    assert_not favorite_last_cooked(days_ago: 44, interval: 10).forgotten? # 4.4x interval
  end

  test 'not forgotten unless favorite' do
    assert_not favorite_last_cooked(days_ago: 130, cooks: 5).forgotten?
  end

  test 'not forgotten when not kid friendly' do
    recipe = favorite_last_cooked(days_ago: 130)
    recipe.kid_status = :not_kid_friendly
    assert_not recipe.forgotten?
  end

  test 'not forgotten when never cooked' do
    assert_not Recipe.new(name: 'Test', cooks_count: 13).forgotten?
  end
end
