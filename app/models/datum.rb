class Datum < ActiveRecord::Base
  belongs_to :user

  def data_time
    series.map{|a| a[0] }
  end

  def data_heart
    series.map{|a| a[1].to_i }
  end

  def data_accel
    series.map{|a| a[2].to_i * 50 - 50 }
  end

end
