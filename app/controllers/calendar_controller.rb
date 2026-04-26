class CalendarController < ApplicationController

  def show
    today = Time.zone.today
    year  = params[:year].presence&.to_i  || today.year
    month = params[:month].presence&.to_i || today.month

    if params[:jump].present?
      year, month = params[:jump].split('-').map(&:to_i)
    end

    @date = Date.new(year, month, 1)
    @range_start = @date.beginning_of_month.beginning_of_week(:sunday)
    @range_end   = @date.end_of_month.end_of_week(:sunday)

    @cooks_by_date = Current.cookbook.cooks
      .includes(:recipe)
      .where(date: @range_start..@range_end)
      .group_by(&:date)
  end

end
