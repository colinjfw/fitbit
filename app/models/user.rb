class User < ActiveRecord::Base
  has_many :data, dependent: :destroy

  def fitbit(options = {})
    Oauth2Rails::Fitbit.new(self, options)
  end

  def get_data(date)
    data = self.data.find_by(date: date)
    if data.nil?
      # fitbit_sleep = self.fitbit.sleep(date).json_body
      # sleep_series = fitbit_sleep['sleep'][0]['minuteData']
      # sleep_info = fitbit_sleep['sleep'][0]
      #
      # heart1 = self.fitbit.minute_heart(1,1,date,'22:00','23:59').json_body               # todo only call this if necessary
      # heart2 = self.fitbit.minute_heart(1,1,date.to_date + 1,'00:00','10:00').json_body
      # values1 = heart1['activities-heart-intraday']['dataset']
      # values2 = heart2['activities-heart-intraday']['dataset']
      # heart_series_init = values1 + values2
      #
      # heart_struc = Hash[heart_series_init.each_with_index.map{ |a,i| [a['time'].to_time.strftime('%I:%M'), i] }]
      # sleep_struc = Hash[sleep_series.map{ |a| [a['dateTime'].to_time.strftime('%I:%M'), a['value']] }]
      #
      # first_index = heart_struc[sleep_info['startTime'].to_time.strftime('%I:%M')]
      # last_index = heart_struc[sleep_series.last['dateTime'].to_time.strftime('%I:%M')]
      #
      # heart_series = heart_series_init[first_index..last_index]
      #
      # main_array = []
      # heart_series.each do |point|
      #   main_array << [ point['time'], point['value'].to_i, sleep_struc[point['time'].to_time.strftime('%I:%M')].to_i  ]
      # end
      # main_array
      #
      # hzone = heart1['activities-heart'][0]['heartRateZones']
      # heart_zones = {
      #   fat_burn: { max: hzone[1]['max'], min: hzone[1]['min'] },
      #   cardio:   { max: hzone[2]['max'], min: hzone[2]['min'] },
      #   peak:     { max: hzone[3]['max'], min: hzone[3]['min'] }
      # }

      data = FitbitData.new.build(self,date)

      Datum.create!(
        user_id: self.id,
        date: date,
        start_time: Time.parse("#{date} #{sleep_info['startTime'].to_time.strftime('%H:%M')}"),
        min_in_bed: sleep_info['timeInBed'].to_i,
        min_awake: sleep_info['minutesAwake'].to_i,
        min_asleep: sleep_info['minutesAsleep'].to_i,
        min_fall_asleep: sleep_info['minutesToFallAsleep'].to_i,
        min_restless: sleep_info['restlessDuration'].to_i,
        series: main_array,
        heart_rate_zones: heart_zones
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
