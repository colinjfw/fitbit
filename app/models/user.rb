class User < ActiveRecord::Base
  has_many :data, dependent: :destroy

  def fitbit(options = {})
    Oauth2Rails::Fitbit.new(self, options)
  end

  def get_data(date)
    data = self.data.find_by(day: date)
    if data.nil?
      fitbit_sleep = self.fitbit.sleep(date).json_body
      fitbit_heart = self.fitbit.minute_heart(1,1,date,'12:00','12:00').json_body # def minute_heart(days, seconds, start_date, start_time, end_time)
      Datum.create!(
        user_id: self.id,
        day: date,
        heart_series: fitbit_heart,
        sleep_series: fitbit_sleep
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
