module Analyzer
  module MovingAverage
    def moving(t)
      moving = [] ; down = t ; up = t
      20.times { moving << heart[down].to_f  if heart[down] ; down -= 1 }
      20.times { moving << heart[up].to_f   if heart[up] ; up += 1 }
      moving
    end
    def moving_accel(t)
      moving = [] ; down = t ; up = t
      20.times { moving << accel[down].to_f  if accel[down] ; down -= 1 }
      20.times { moving << accel[up].to_f   if accel[up] ; up += 1 }
      moving
    end
  end

  class HrData
    include MovingAverage
    attr_accessor :heart, :accel, :stage, :inter, :start
    def initialize(options = {})
      @heart = options[:heart] || []
      @accel = options[:accel] || []
      @stage = options[:stage] || []
      @inter = options[:inter] || '1s'
      @start = options[:start] || nil
    end
    def moving_volatility
      hr_vol = []
      heart.each_with_index { |datum, t| hr_vol << moving(t).volatility }
      hr_vol
    end
    def moving_average
      hr_avg = []
      heart.each_with_index { |datum, t| ; hr_avg << moving(t).average }
      hr_avg
    end
    def fixed_average
      hr_avg = []
      heart.each_with_index { |datum, t| ; hr_avg << heart.average }
      hr_avg
    end
    def fixed_volatility
      hr_vol = []
      heart.each_with_index { |datum, t| hr_vol << heart.volatility }
      hr_vol
    end
    def self.analyze_data(options = {})
      data = self.new(options)
      Analyze.new(data).analyze
    end
  end

  class Analyze
    include MovingAverage
    attr_accessor :dat_o, :heart, :accel
    def initialize(data_object)
      @dat_o = data_object
      @heart = data_object.heart
      @accel = data_object.accel
      @sample_size = @heart.size
    end
    def analyze
      User.fitbit_logger.info "ANALYZER: Analyze" ; ana = Time.now
      stages = [] ; avg = heart.average
      heart.each_with_index do |datum, t|
        mov = moving(t) ; mov_avg = mov.average ; mov_accel = moving_accel(t)
        if mov_accel.include?(2) or mov_accel.include?(3) # awake
          stages << 0
        elsif mov_avg > avg                               # rem or light
          if stages[t - 5] >= 2                           # rem
            stages << 3
          else                                            # light
            stages << 1
          end
        elsif mov_avg <= avg                              # deep
          stages << 2
        else                                              # can't find one
          stages << 10
        end
        Rails.logger.info "#{t} analyzer loop"
      end
      User.fitbit_logger.info "ANALYZER: Analyze end      #{Time.now - ana}"
      @dat_o.stage = stages
      @dat_o
    end
  end

end