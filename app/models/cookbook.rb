class Cookbook < ApplicationRecord
  has_many :recipes,  dependent: :destroy
  has_many :sections, dependent: :destroy
  has_many :users,    dependent: :destroy

  has_many :cooks, through: :recipes

  def favorite_benchmark
    2 * cooks_stddev
  end

  def forgotten_benchmark
    time_deviations * last_cooked_stddev
  end

  def cooks_stddev
    @cooks_stddev ||= recipes.where.not(cooks_count: 0).pluck(:cooks_count).standard_deviation
  end

  def last_cooked_stddev
    @last_cooked_stddev ||= recipes.where.not(last_cooked_on: nil).pluck(Arel.sql("date_part('day', age(last_cooked_on))")).standard_deviation
  end

  def time_deviations
    @time_deviations ||= (365.0 / recipes.where.not(cooks_count: 0).count).floor
  end
end
