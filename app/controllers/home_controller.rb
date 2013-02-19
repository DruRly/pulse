class HomeController < ApplicationController
  def index
    #@counts = Petition.all.map(&:last_365_days_signature_counts)
    @h = LazyHighCharts::HighChart.new('graph') do |f|
      f.options[:chart][:defaultSeriesType] = "area"
      Petition.all.map do |p|
        f.series(data: p.last_365_days_growth_rates, showInLegend: false)
      end
    end
  end
end
