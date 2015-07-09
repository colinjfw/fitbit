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
      Rails.logger.info 'CALL SLEEP'
      sleep = @user.fitbit.sleep(@date).json_body
      if sleep['sleep'][0]
        @sleep_series = sleep['sleep'][0]['minuteData']
        sleep_info    = sleep['sleep'][0]
        @sleep_info = {
          min_in_bed: sleep_info['timeInBed'].to_i,
          min_awake: sleep_info['minutesAwake'].to_i,
          min_asleep: sleep_info['minutesAsleep'].to_i,
          min_fall_asleep: sleep_info['minutesToFallAsleep'].to_i,
        }
        @start_time = Time.parse("#{@date} #{sleep_info['startTime'].to_time.strftime('%H:%M')}")
        @end_time   = Time.parse("#{@date} #{@sleep_series.last['dateTime']}")
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
      Rails.logger.info 'CALL HEART'
      if @start_time < '00:00'
        heart1 = @user.fitbit.minute_heart(1,1,@date,strf_start,'23:59').json_body
        heart2 = @user.fitbit.minute_heart(1,1,@date.to_date + 1,'00:00',strf_end).json_body
        @heart_series = heart1['activities-heart-intraday']['dataset'] + heart2['activities-heart-intraday']['dataset']
      else
        heart1 = @user.fitbit.minute_heart(1,1,@date,strf_start,strf_end).json_body
        @heart_series = heart1['activities-heart-intraday']['dataset']
      end
      hzone = heart1['activities-heart'][0]['heartRateZones']
      Rails.logger.info 'FINISH CALL HEART'
      @heart_zones = {
        fat_burn: { max: hzone[1]['max'], min: hzone[1]['min'] },
        cardio:   { max: hzone[2]['max'], min: hzone[2]['min'] },
        peak:     { max: hzone[3]['max'], min: hzone[3]['min'] }
      }
    end

    def sleep_structure
      Hash[@sleep_series.map{ |a| [ a['dateTime'].to_time.strftime('%H:%M'), a['value'] ] }]
    end

    def build_main_array
      Rails.logger.info 'Building main array'
      analyzed = call_analyzer
      @heart_series.each_with_index do |val, t|
        Rails.logger.info "#{t} inside main array"
        @main_array << [
          @data_time[t],                   # time
          @data_heart[t],                  # heart rate
          @data_accel[t],                  # accel data
          analyzed[:stages][t],            # stages
          analyzed[:moving_average][t],    # moving average
          analyzed[:fixed_average][t],     # fixed average
          analyzed[:moving_volatility][t]  # moving vol
        ]
      end
      Rails.logger.info 'Finished building main array'
    end

    def build_data_values
      Rails.logger.info 'BUILDING DATA VALUES'
      structure = sleep_structure
      @heart_series.each_with_index do |val, t|
        Rails.logger.info "#{t} inside data values"
        time = val['time'].to_time.strftime('%H:%M')
        @data_time << time
        @data_heart << val['value']
        @data_accel << structure[time] ? structure[time].to_i : 0
      end
      Rails.logger.info 'Finished data values'
    end

    def call_analyzer
      Rails.logger.info 'Calling HrData analyze from gather data'
      data = Analyzer::HrData.analyze_data(heart: data_heart, accel: data_accel)
      Rails.logger.info 'Finished calling HrData analyze from gather data'
      { moving_average: data.moving_average, fixed_average: data.fixed_average,
        moving_volatility: data.moving_volatility, stages: data.stage }
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