module Analyzer
  module MovingAverage
    def moving(t)
      moving = [] ; down = t ; up = t
      10.times { moving << heart[down]  if heart[down] ; down -= 1 }
      10.times { moving << heart[up]    if heart[up] ; up += 1 }
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
      Rails.logger.info 'Calling HrData'
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
    def rem?(t)
      if t < @sample_size * 0.20 || t > @sample_size * 0.10
        mov = moving(t)
        mov.average > heart.average ? avg = true : avg = false
        # mov.volatility > heart.volatility ? vol = true : vol = false
        # accel[t] > 1 ? acc = true : acc = false
        # mov.variance > heart.variance ? var = true : var = false
        avg
      else
        false
      end
    end
    def deep?(t)
      mov = moving(t)
      mov.average < heart.average ? avg = true : avg = false
      mov.volatility < heart.volatility ? vol = true : vol = false
      # mov.variance < heart.variance ? var = true : var = false
      vol && avg # && var
    end
    def medium?(t)
      mov = moving(t)
      mov.average.approx_equal?(heart.average) ? avg = true : avg = false
      mov.volatility.approx_equal?(heart.volatility) ? vol = true : vol = false
      # mov.variance.approx_equal?(heart.variance) ? var = true : var = false
      vol && avg # && var
    end
    def light?(t)
      mov = moving(t)
      mov.average > heart.average ? avg = true : avg = false
      mov.volatility.approx_equal?(heart.volatility) ? vol = true : vol = false
      accel[t].to_i > 1 ? acc = true : acc = false
      # mov.variance > heart.variance ? var = true : var = false
      vol && avg && acc # && var
    end
    def analyze
      Rails.logger.info "ANALYZER: Analyze #{ana = Time.now; ana}"
      stages = []
      heart.each_with_index do |datum, t|
        if    rem?(t)     ; stages << 4
        elsif deep?(t)    ; stages << 3
        elsif medium?(t)  ; stages << 2
        elsif light?(t)   ; stages << 1
        else              ; stages << 0
        end
      end
      Rails.logger.info "ANALYZER: Analyze end #{Time.now - ana}"
      @dat_o.stage = stages
      @dat_o
    end
  end

end