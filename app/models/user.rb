class User < ActiveRecord::Base
  has_many :data, dependent: :destroy
  include FitbitOauth2::RailsUser

  def average_nightly_sleep
    tot = []
    self.data.each do |datum|
      tot << datum.minutes_asleep.to_f if datum.sleep && datum.minutes_asleep
    end
    ((tot.sum / tot.count) / 60).round(2)
  end

end
