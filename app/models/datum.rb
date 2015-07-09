class Datum < ActiveRecord::Base
  belongs_to :user

  def sleep
    sleep_series['sleep'][0] if sleep_series['sleep'] && sleep_series['sleep'][0]
  end

  def heart_info
    heart_series['info']
  end

  def heart_data
    heart_series['dataset']
  end

  def time_in_bed
    sleep['timeInBed']
  end

  def start_time
    sleep['startTime']
  end

  def efficiency
    sleep['efficiency']
  end

  def minutes_awake
    sleep['minutesAwake']
  end

  def minutes_asleep
    sleep['minutesAsleep']
  end

  def minute_data
    sleep['minuteData']
  end

  def minute_data_times
    val = []
    count = 0
    minute_data.each do |element|
      if count % 20 == 0
        val << element['dateTime'].to_time.strftime('%H:%M').to_s
      else
        val << ''
      end
      count += 1
    end
    val
  end

  def minute_data_values
    val = []
    minute_data.each do |element|
      val << element['value'].to_i
    end
    val
  end

  def end_time
    minute_data.last['dateTime']
  end

  def hr_during_sleep
    start = heart_data.index(heart_data.find { |time| time['time'].to_time.strftime('%I:%M') == self.start_time.to_time.strftime('%I:%M') })
    endt  = heart_data.index(heart_data.find { |time| time['time'].to_time.strftime('%I:%M') == self.end_time.to_time.strftime('%I:%M') })
    heart_data[start..endt]
  end

  def main_data
    main_array = []
    hr_during_sleep.each do |point|
      # main_array = [ time, heartrate, movement ]
      sleep = minute_data.find { |time| time['dateTime'].to_time.strftime('%I:%M') == point['time'].to_time.strftime('%I:%M') }
      main_array << [ point['time'], point['value'], sleep['value'] ]
    end
    main_array
  end

end
