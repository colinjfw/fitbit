class User < ActiveRecord::Base
  has_many :data, dependent: :destroy

  def fitbit(options = {})
    Oauth2Rails::Fitbit.new(self, options)
  end

  def process_heart_data(json1, json2)
    values1 = json1['activities-heart-intraday']['dataset']
    values2 = json2['activities-heart-intraday']['dataset']
    values = values1 +  values2
    data = {
      info: {
        interval: json1['activities-heart-intraday']['datasetInterval'],
        interval_type: json1['activities-heart-intraday']['datasetType'],
        start_date: json1['activities-heart'][0]['dateTime'],
        start_time: json1['activities-heart-intraday']['dataset'][0].values[0],
        end_time:   json2['activities-heart-intraday']['dataset'].last.values[0]
      },
      dataset: values
    }
    data.to_json
  end

  def get_data(date)
    data = self.data.find_by(day: date)
    if data.nil?
      fitbit_sleep = self.fitbit.sleep(date).json_body
      heart1 = self.fitbit.minute_heart(1,1,date,'22:00','23:59').json_body
      heart2 = self.fitbit.minute_heart(1,1,date.to_date + 1,'00:00','10:00').json_body
      fitbit_heart = process_heart_data(heart1,heart2)
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
