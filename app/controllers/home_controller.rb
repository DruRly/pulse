class HomeController < ApplicationController
  def index
    @h = LazyHighCharts::HighChart.new('graph') do |f|
      f.options[:chart][:defaultSeriesType] = "area"
      Petition.first(10).map do |p|
        f.series(data: p.last_365_days_growth_rates, showInLegend: false)
      end
    end
  end
end
