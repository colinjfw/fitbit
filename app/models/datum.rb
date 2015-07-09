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

  def data_time
    series.map{|a| a[0] }
  end

  def data_heart
    series.map{|a| a[1].to_i }
  end

  def data_accel
    series.map{|a| a[2].to_i * 20 - 20 }
  end

  def data_stages
    series.map{|a| a[3].to_i * 20 - 20 }
  end

  def data_mov_average
    series.map{|a| a[4].to_i }
  end

  def data_fixed_average
    series.map{|a| a[5].to_i }
  end

  def data_moving_volatility
    series.map{|a| a[6].to_i + 100 }
  end

end
