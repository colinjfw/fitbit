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
    data = self.data.find_by(date: date)
    if data.nil?
      heart1 = self.fitbit.minute_heart(1,1,date,'22:00','23:59').json_body
      heart2 = self.fitbit.minute_heart(1,1,date.to_date + 1,'00:00','10:00').json_body
      values1 = heart1['activities-heart-intraday']['dataset']
      values2 = heart2['activities-heart-intraday']['dataset']
      heart_series = values1 + values2

      fitbit_sleep = self.fitbit.sleep(date).json_body
      fitbit_sleep['sleep'] ? sleep_series = fitbit_sleep['sleep'][0] : sleep_series = {}

      main_array = []
      heart_series.each do |point|
        sleep_val = sleep_series['minuteData'].find { |time| time['dateTime'].to_time.strftime('%I:%M') == point['time'].to_time.strftime('%I:%M') }
        main_array << [ point['time'], point['value'], sleep_val['value'] ]
      end
      main_array

      Datum.create!(
        user_id: self.id,
        date: date,
        start_time: sleep_series['startTime'],
        time_in_bed: sleep_series['timeInBed'],
        time_awake: sleep_series['minutesAwake'],
        time_asleep: sleep_series['minutesAsleep'],
        series: main_array
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
