class Datum < ActiveRecord::Base
  belongs_to :user

  def data_time
    series.map{|a| a[0]}
  end

  def data_heart
    series.map{|a| a[1]}
  end

  def data_accel
    series.map{|a| a[2]}
  end

end
