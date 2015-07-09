module FitbitData
  include Analyzer
  class GatherData
    attr_accessor :heart_series, :heart_zones, :sleep_series, :sleep_info, :start_time, :end_time

    def initialize(user, date)
      @user         = user
      @date         = date
      @heart_series = {}
      @heart_zones  = {}
      @sleep_series = {}
      @sleep_info   = {}
      @start_time   = nil
      @end_time     = nil
    end

    def call_sleep
      sleep = @user.fitbit.sleep(@date).json_body
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
    end

    def strf_start
      @start_time.strftime('%H:%M')
    end

    def strf_end
      @end_time.strftime('%H:%M')
    end

    def call_heart
      if @start_time < '00:00'
        heart1 = @user.fitbit.minute_heart(1,1,@date,strf_start,'23:59').json_body
        heart2 = @user.fitbit.minute_heart(1,1,@date.to_date + 1,'00:00',strf_end).json_body
        @heart_series = heart1['activities-heart-intraday']['dataset'] + heart2['activities-heart-intraday']['dataset']
      else
        heart1 = @user.fitbit.minute_heart(1,1,@date,strf_start,strf_end).json_body
        @heart_series = heart1['activities-heart-intraday']['dataset']
      end
      hzone = heart1['activities-heart'][0]['heartRateZones']
      @heart_zones = {
        fat_burn: { max: hzone[1]['max'], min: hzone[1]['min'] },
        cardio:   { max: hzone[2]['max'], min: hzone[2]['min'] },
        peak:     { max: hzone[3]['max'], min: hzone[3]['min'] }
      }
    end

    def sleep_structure
      Hash[@sleep_series.map{ |a| [ a['dateTime'].to_time.strftime('%H:%M'), a['value'] ] }]
    end

    def main_array
      main = []
      @heart_series.each do |val|
        time  = val['time'].to_time.strftime('%H:%M')
        hr    = val['value'].to_i
        move  = sleep_structure[time] ? sleep_structure[time].to_i : 0
        main << [ time, hr, move ]
      end
      main
    end

    def main_array_with_analyze
      logger.info 'Building main array'
      main = []
      analyzed = analyze
      @heart_series.each_with_index do |val, t|
        time    = val['time'].to_time.strftime('%H:%M')
        main << [
          val['time'].to_time.strftime('%H:%M'),
          val['value'],
          sleep_structure[time] ? sleep_structure[time] : 0,
          analyzed[:stages][t],
          analyzed[:moving_average][t],
          analyzed[:fixed_average][t],
          analyzed[:moving_volatility][t]
        ]
      end
      main
    end

    def data_accel
      main_array.map{|a| a[2].to_i }
    end

    def data_heart
      main_array.map{|a| a[1].to_i }
    end

    def analyze
      logger.info 'Calling HrData analyze from gather data'
      data = Analyzer::HrData.analyze(heart: data_heart, accel: data_accel)
      {
        moving_average: data.moving_average,
        fixed_average: data.fixed_average,
        moving_volatility: data.moving_volatility,
        stages: data.stage
      }
    end

    def self.build(user, date)
      build = self.new(user, date)
      build.call_sleep
      build.call_heart
      build
    end

  end
end