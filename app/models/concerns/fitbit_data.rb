module FitbitData
  include Analyzer
  class GatherData
    attr_accessor :heart_series, :heart_zones, :sleep_series, :sleep_info,
                  :start_time, :end_time, :main_array, :data_heart, :data_accel,
                  :data_time

    def initialize(user, date)
      @user         = user
      @date         = date
      @heart_series = {}
      @heart_zones  = {}
      @sleep_series = {}
      @sleep_info   = {}
      @start_time   = nil
      @end_time     = nil
      @main_array   = []
      @data_heart   = []
      @data_accel   = []
      @data_time    = []
    end

    def call_sleep
      User.fitbit_logger.info "DATA: Call sleep" ; cs = Time.now
      sleep = @user.fitbit.sleep(@date).json_body
      User.fitbit_logger_json.info "\n\n\n\n\n\n\n\n------SLEEP SERIES RESULT-----\n#{sleep}"
      if sleep['sleep'][0]
        @sleep_series = sleep['sleep'][0]['minuteData']
        sleep_info    = sleep['sleep'][0]
        @sleep_info = {
          min_in_bed: sleep_info['timeInBed'].to_i,
          min_awake: sleep_info['minutesAwake'].to_i,
          min_asleep: sleep_info['minutesAsleep'].to_i,
          min_fall_asleep: sleep_info['minutesToFallAsleep'].to_i,
        }
        @start_time = sleep_info['startTime'].to_time
        User.fitbit_logger.info "DATA: start time before parsed #{sleep_info['startTime']}"
        User.fitbit_logger.info "DATA: start time after parsed  #{sleep_info['startTime'].to_time}"
        @end_time   = Time.parse("#{@date} #{@sleep_series.last['dateTime']}")
        User.fitbit_logger.info "DATA: Call sleep end       #{Time.now - cs}"
      else
        raise NoDataError, 'Could not find any sleep data'
      end
    end

    def strf_start
      @start_time.strftime('%H:%M')
    end

    def strf_end
      @end_time.strftime('%H:%M')
    end

    def call_heart
      User.fitbit_logger.info "DATA: Call heart" ; ch = Time.now
      User.fitbit_logger.info "API CALL: start time                         = #{strf_start}"
      User.fitbit_logger.info "API CALL: end time                           = #{strf_end}"
      User.fitbit_logger.info "API CALL: @start_time.day != @end_time.day   = #{@start_time.day != @end_time.day}"
      if @start_time.day != @end_time.day
        heart1 = @user.fitbit.minute_heart(1,1,@date,strf_start,'23:59').json_body
        heart2 = @user.fitbit.minute_heart(1,1,@date.to_date + 1,'00:00',strf_end).json_body
        @heart_series = heart1['activities-heart-intraday']['dataset'] + heart2['activities-heart-intraday']['dataset']
      else
        heart1 = @user.fitbit.minute_heart(1,1,@date,strf_start,strf_end).json_body
        @heart_series = heart1['activities-heart-intraday']['dataset']
      end
      User.fitbit_logger_json.info "\n\n\n------HEART SERIES RESULT-----\n#{heart1}\n\n\n\n\n\n\n#{heart2 if heart2}"
      hzone = heart1['activities-heart'][0]['heartRateZones']
      User.fitbit_logger.info "DATA: Call heart end       #{Time.now - ch}"
      User.fitbit_logger.info "API CALL: start time from heart series       = #{@heart_series.first['time']}"
      User.fitbit_logger.info "API CALL: end time from heart series         = #{@heart_series.last['time']}"
      resting = @user.fitbit.daily_heart(@date).json_body['activities-heart'][0]['value']['restingHeartRate']
      @heart_zones = {
        resting: resting,
        fat_burn: { max: hzone[1]['max'], min: hzone[1]['min'] },
        cardio:   { max: hzone[2]['max'], min: hzone[2]['min'] },
        peak:     { max: hzone[3]['max'], min: hzone[3]['min'] }
      }
    end

    def sleep_structure
      Hash[@sleep_series.map{ |a| [ a['dateTime'].to_time.strftime('%H:%M'), a['value'] ] }]
    end

    def build_main_array
      User.fitbit_logger.info "DATA: Build main array" ; bm = Time.now
      call_analyzer
      @heart_series.each_with_index do |val, t|
        Rails.logger.info "#{t} build main array"
        @main_array << [
          @data_time[t],         # time
          @data_heart[t],        # heart rate
          @data_accel[t],        # accel data
          @stages[t],            # stages
          @moving_average[t],    # moving average
          @fixed_average[t],     # fixed average
          @moving_volatility[t]  # moving vol
        ]
      end
      User.fitbit_logger.info "DATA: Build main array end #{Time.now - bm}"
    end

    def build_data_values
      User.fitbit_logger.info "DATA: Build data value" ; dv = Time.now
      structure = sleep_structure
      @heart_series.each_with_index do |val, t|
        Rails.logger.info "#{t} build data values loop"
        time = val['time'].to_time.strftime('%H:%M')
        @data_time << time
        @data_heart << val['value']
        @data_accel << structure[time] ? structure[time].to_i : 0
      end
      User.fitbit_logger.info "DATA: Build data value end #{Time.now - dv}"
    end

    def call_analyzer
      data = Analyzer::HrData.analyze_data(heart: data_heart, accel: data_accel)
      @moving_average = data.moving_average
      @fixed_average = data.fixed_average
      @moving_volatility = data.moving_volatility
      @stages = data.stage
    end

    def log_results
      User.fitbit_logger_json.info "------HEART SERIES RESULT-----\n#{@heart_series}"
    end

    def self.build(user, date)
      build = self.new(user, date)
      build.call_sleep
      build.call_heart
      build.build_data_values
      build.build_main_array
      build
    end

  end

  class NoDataError < StandardError
  end

end