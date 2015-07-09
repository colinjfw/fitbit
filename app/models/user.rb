class User < ActiveRecord::Base
  has_many :data, dependent: :destroy
  include FitbitData

  def fitbit(options = {})
    Oauth2Rails::Fitbit.new(self, options)
  end

  def get_data(date)
    data = self.data.find_by(date: date)
    if data.nil?
      logger.info "About to call GatherData #{start = Time.now ; start}"
      data = GatherData.build(self, date)
      logger.info "Finished calling GatherData #{start - Time.now}"
      Datum.create!(
        user_id: self.id,
        date: date,
        start_time:         data.start_time,
        min_in_bed:         data.sleep_info[:min_in_bed],
        min_awake:          data.sleep_info[:min_awake],
        min_asleep:         data.sleep_info[:min_asleep],
        min_fall_asleep:    data.sleep_info[:min_fall_asleep],
        min_restless:       data.sleep_info[:min_restless],
        series:             data.main_array_with_analyze,
        heart_rate_zones:   data.heart_zones
      )
    else
      data
    end
  end

  def average_nightly_sleep
    tot = []
    self.data.each do |datum|
      tot << datum.minutes_asleep.to_f if datum.sleep && datum.minutes_asleep
    end
    ((tot.sum / tot.count) / 60).round(2)
  end

end
