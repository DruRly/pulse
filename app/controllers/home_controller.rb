class HomeController < ApplicationController
  def index
    @h = LazyHighCharts::HighChart.new('graph') do |f|
      f.options[:chart][:defaultSeriesType] = "area"
      Petition.first(30).map do |p|
        f.series(data: p.days_growth_rates(90), showInLegend: false)
      end
    end

    @rankings = Petition.top_by_average(5)
    @near_threshold = Petition.near_threshold(5)
  end
end
