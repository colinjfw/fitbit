class User < ActiveRecord::Base
  has_many :data, dependent: :destroy

  def fitbit(options = {})
    Oauth2Rails::Fitbit.new(self, options)
  end

  def get_data(date)
    data = self.data.find_by(date: date)
    if data.nil?
      fitbit_sleep = self.fitbit.sleep(date).json_body
      fitbit_sleep['sleep'] ? sleep_series = fitbit_sleep['sleep'][0] : sleep_series = {}

      heart1 = self.fitbit.minute_heart(1,1,date,'22:00','23:59').json_body               # todo only call this if necessary
      heart2 = self.fitbit.minute_heart(1,1,date.to_date + 1,'00:00','10:00').json_body
      values1 = heart1['activities-heart-intraday']['dataset']
      values2 = heart2['activities-heart-intraday']['dataset']
      heart_series_init = values1 + values2

      heart_struc = Hash[heart_series_init.each_with_index.map{ |a,i| [a['time'].to_time.strftime('%I:%M'), i] }]
      sleep_struc = Hash[sleep_series.map{ |a,i| [a['dateTime'].to_time.strftime('%I:%M'), a['value']] }]

      first_index = heart_struc[sleep_series['startTime'].to_time.strftime('%I:%M')]
      last_index = heart_struc[sleep_series.last['dateTime'].to_time.strftime('%I:%M')]

      heart_series = heart_series_init[first_index..last_index]

      main_array = []
      heart_series.each do |point|
        main_array << [ point['time'], point['value'], sleep_struc[point['time'].to_time.strftime('%I:%M')]  ]
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
