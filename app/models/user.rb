class User < ActiveRecord::Base
  has_many :data, dependent: :destroy
  include FitbitData

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }

  def to_param
    "#{id}-#{name.parameterize}"
  end

  def password
    @password ||= BCrypt::Password.new(password_hash)
  end

  def password=(new_password)
    @password = BCrypt::Password.create(new_password)
    self.password_hash = @password
  end

  def state
    Base64.strict_encode64("#{csrf_token}:#{id}")
  end

  def self.fitbit_logger
    @@fitbit_logger ||= Logger.new("#{Rails.root}/log/fitbit.log")
  end

  def self.fitbit_logger_json
    @@fitbit_logger_json ||= Logger.new("#{Rails.root}/log/fitbit_json.log")
  end

  def self.iterations_logger
    @@iterations_logger ||= Logger.new("#{Rails.root}/log/iterations.log")
  end

  def fitbit(options = {})
    Oauth2Rails::Fitbit.new(self, options)
  end

  def get_data(date)
    data = self.data.find_by(date: date)
    if data.nil?
      User.fitbit_logger.info "START GATHER DATA #{start = Time.now ; start}"
      new_data = GatherData.build(self, date)
      built_data = Datum.create!(
        user_id: self.id,
        date: date,
        start_time:         new_data.start_time,
        min_in_bed:         new_data.sleep_info[:min_in_bed],
        min_awake:          new_data.sleep_info[:min_awake],
        min_asleep:         new_data.sleep_info[:min_asleep],
        min_fall_asleep:    new_data.sleep_info[:min_fall_asleep],
        min_restless:       new_data.sleep_info[:min_restless],
        series:             new_data.main_array,
        heart_rate_zones:   new_data.heart_zones
      )
      User.fitbit_logger.info "END GATHER DATA #{Time.now - start}"
      User.fitbit_logger.info "DATA: start time after db   #{built_data.start_time}"
      built_data
    else
      data
    end
  end

  def re_analyze_data(date)
    data = self.data.find_by(date: date)
    analyzed_data = Analyzer::HrData.analyze_data(heart: data.data_heart, accel: data.data_accel)
    series = data.series ; stages = analyzed_data.stage
    series.each_with_index do |val, t|
      series[t][3] = stages[t]
    end
    updated = data.update(
      user_id: self.id,
      series: series,
    )
    self.data.find_by(date: date)
  end

  def average_nightly_sleep
    tot = []
    self.data.each do |datum|
      tot << datum.minutes_asleep.to_f if datum.sleep && datum.minutes_asleep
    end
    ((tot.sum / tot.count) / 60).round(2)
  end

end
