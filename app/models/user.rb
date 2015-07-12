class User < ActiveRecord::Base
  has_many :data, dependent: :destroy
  include FitbitData

  def fitbit(options = {})
    Oauth2Rails::Fitbit.new(self, options)
  end

  def get_data(date)
    data = self.data.find_by(date: date)
    if data.nil?
      logger.info "START GATHER DATA #{start = Time.now ; start}"
      new_data = GatherData.build(self, date)
      built_data = Datum.create!(
        user_id: self.id,
        date: date,
        start_time:         new_data.start_time,
        min_in_bed:         new_data.sleep_info[:min_in_bed],
        min_awake:          new_data.sleep_info[:min_awake],
        min_asleep:         new_data.sleep_info[:min_asleep],
        min_fall_asleep:    new_data.sleep_info[:min_fall_asleep],
        min_restless:       new_data.sleep_info[:min_restless],
        series:             new_data.main_array,
        heart_rate_zones:   new_data.heart_zones
      )
      logger.info "END GATHER DATA #{Time.now - start}"
      built_data
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
