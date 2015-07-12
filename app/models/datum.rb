class Datum < ActiveRecord::Base
  belongs_to :user

  # ==> DATA STRUCTURE
  # series[0] => time
  # series[1] => heart rate
  # series[2] => accel data
  # series[3] => stages
  # series[4] => moving average
  # series[5] => fixed average
  # series[6] => moving volatility

  def data_resting
    rest = heart_rate_zones['resting'] ; data = [] ; count = series.length
    count.times { |a| data << rest }
    data
  end

  def average_sleep(user)
    user.data.all.pluck(:min_asleep).average
  end

  def data_time
    series.map{|a| a[0] }
  end

  def data_heart
    series.map{|a| a[1].to_f }
  end

  def data_accel
    series.map{|a| a[2].to_f }
  end

  def data_stages
    series.map{|a| a[3].to_f }
  end

  def data_mov_average
    series.map{|a| a[4].to_f.round(2) }
  end

  def data_fixed_average
    series.map{|a| a[5].to_f.round(2) }
  end

  def data_moving_volatility
    series.map{|a| a[6].to_f.round(2) }
  end

  def test_rem_cutoff
    cut = data_fixed_average[0] * 1.3 ; data = [] ; count = series.length
    count.times { |a| data << cut }
    data
  end

  def data(user)
    {
      volatSeries: [
        {
          values: data_moving_volatility,
          "data-days": data_time,
          "text": "Moving Volatility",
          "line-color": "#666699",
          "alpha-area": 0.3,
          "background-color": "#666699",
          "line-width": 1.5,
          "legend-marker": {
            "type": "circle",
            "size": 5,
            "background-color": "#666699",
            "border-width": 1,
            "shadow": 0,
            "border-color": "#666"
          },
          "marker": {
            "background-color": "#da534d",
            "border-width": 1,
            "shadow": 0,
            "border-color": "#faa39f"
          }
        },
      ],
      sleepSeries: [
        {
          values: data_accel,
          "data-days": data_time,
          "text": "Accelerometer",
          "line-color": "#009872",
          "alpha-area": 0,
          "line-width": 1.5,
          "legend-marker": {
            "type": "circle",
            "size": 5,
            "background-color": "#009872",
            "border-width": 1,
            "shadow": 0,
            "border-color": "#666"
          },
          "marker": {
            "background-color": "#009872",
            "border-width": 1,
            "shadow": 0,
            "border-color": "#69f2d0"
          }
        },
        {
          values: data_stages,
          "data-days": data_time,
          "text": "Sleep Stages",
          "alpha-area": 0.6,
          "background-color": "#FF66CC",
          "line-color": "#FF66CC",
          "line-width": 1.5,
          "legend-marker": {
            "type": "circle",
            "size": 5,
            "background-color": "#FF66CC",
            "border-width": 1,
            "shadow": 0,
            "border-color": "#666"
          },
          "marker": {
            "background-color": "#da534d",
            "border-width": 1,
            "shadow": 0,
            "border-color": "#faa39f"
          }
        },
      ],
      heartSeries: [
        {
          values: data_heart,
          "data-days": data_time,
          "text": "Heart Rate",
          "line-color": "#007790",
          "alpha-area": 0.3,
          "background-color": "#007790",
          "line-width": 1,
          "legend-marker": {
            "type": "circle",
            "size": 5,
            "background-color": "#007790",
            "border-width": 1,
            "shadow": 0,
            "border-color": "#666"
          },
          "marker": {
            "background-color": "#007790",
            "border-width": 1,
            "shadow": 0,
            "border-color": "#69dbf1"
          }
        },
        {
          values: data_resting,
          "data-days": data_time,
          "text": "Resting Heart Rate",
          "line-color": "#9966FF",
          "alpha-area": 0,
          "line-width": 1.5,
          "legend-marker": {
            "type": "circle",
            "size": 5,
            "background-color": "#9966FF",
            "border-width": 1,
            "shadow": 0,
            "border-color": "#666"
          },
          "marker": {
            "background-color": "#007790",
            "border-width": 1,
            "shadow": 0,
            "border-color": "#69dbf1"
          }
        },
        {
          values: data_mov_average,
          "data-days": data_time,
          "text": "Moving Average",
          "line-color": "#66CCFF",
          "alpha-area": 0,
          "line-width": 1.5,
          "legend-marker": {
            "type": "circle",
            "size": 5,
            "background-color": "#66CCFF",
            "border-width": 1,
            "shadow": 0,
            "border-color": "#666"
          },
          "marker": {
            "background-color": "#da534d",
            "border-width": 1,
            "shadow": 0,
            "border-color": "#faa39f"
          }
        },
        {
          values: data_fixed_average,
          "data-days": data_time,
          "text": "Fixed Average",
          "line-color": "#666",
          "alpha-area": 0,
          "line-width": 1.5,
          "legend-marker": {
            "type": "circle",
            "size": 5,
            "background-color": "#666",
            "border-width": 1,
            "shadow": 0,
            "border-color": "#666"
          },
          "marker": {
            "background-color": "#da534d",
            "border-width": 1,
            "shadow": 0,
            "border-color": "#faa39f"
          }
        },
        {
          values: test_rem_cutoff,
          "data-days": data_time,
          "text": "Rem Cutoff",
          "line-color": "#CC0000",
          "alpha-area": 0,
          "line-width": 1,
          "legend-marker": {
            "type": "circle",
            "size": 5,
            "background-color": "#CC0000",
            "border-width": 1,
            "shadow": 0,
            "border-color": "#666"
          },
          "marker": {
            "background-color": "#da534d",
            "border-width": 1,
            "shadow": 0,
            "border-color": "#faa39f"
          }
        }
      ],
      xAxis: data_time,
      averageSleep: (average_sleep(user).to_f / 60).round(2),
      startTime: start_time.in_time_zone('Pacific Time (US & Canada)').strftime('%H:%M'),
      timeAwake: min_awake,
      efficiency: ((min_asleep.to_f / min_in_bed.to_f)).round(2) * 100,
      timeAsleep: (min_asleep.to_f / 60).round(2),
      timeInBed: (min_in_bed.to_f / 60).round(2),
    }
  end

end
