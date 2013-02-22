class HomeController < ApplicationController
  def index
    @issues = Issue.all.map(&:name).unshift("All Issues")
    if (params[:issue] && Petition.all.select {|p| p.issues.map(&:name).include?(params[:issue])})
      @petitions = Petition.all.select { |p| p.issues.map(&:name).include?(params[:issue]) }
      #selected
    else
      #non specific
    end

    @h = LazyHighCharts::HighChart.new('graph') do |f|
      f.options[:chart][:defaultSeriesType] = "area"
      #this is going to use the petitions class variable
      Petition.first(3).map do |p|
        f.series(data: p.days_growth_rates(90), showInLegend: false, name: p.title)
      end
    end

    @rankings = Petition.top_by_average(5)
    @near_threshold = Petition.near_threshold(5)
  end
end
