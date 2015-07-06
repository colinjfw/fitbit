class Datum < ActiveRecord::Base
  belongs_to :user

  def sleep
    sleep_series['sleep'][0] if sleep_series['sleep'] && sleep_series['sleep'][0]
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

end
