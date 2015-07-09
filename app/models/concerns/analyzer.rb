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
      heart.each_with_index do |datum, t|
        hr_vol << moving(t).volatility
      end
      hr_vol
    end

    def moving_average
      hr_avg = []
      heart.each_with_index do |datum, t|
        hr_avg << moving(t).average
      end
      hr_avg
    end

    def fixed_average
      hr_avg = []
      heart.each_with_index do |datum, t|
        hr_avg << heart.average
      end
      hr_avg
    end

    def fixed_volatility
      hr_vol = []
      heart.each_with_index do |datum, t|
        hr_vol << heart.volatility
      end
      hr_vol
    end

    def graph
      puts ' '
      puts ' '
      heart.each do |datum|
        puts '-' * datum
      end
      puts ' '
    end

    def table
      puts ' '
      puts ' '
      puts '         OVERALL                '
      puts "     Average: #{heart.average.round(2)}   "
      puts "  Volatility: #{heart.volatility.round(2)}"
      puts "    Variance: #{heart.variance.round(2)}"
      puts ' '
      puts '|       |       |  mov  |  mov  |  mov  |  mov  |  mov  |       |'
      puts '|   t   |   hr  |  avg  |  vol  |  var  |avg-avg|vol-vol| stage |'
      puts '|-------|-------|-------|-------|-------|-------|-------|-------|'
      heart.each_with_index do |datum, t|
        pad = 7
        mov = moving(t)
        avg_diff = mov.average - heart.average
        vol_diff = mov.volatility - heart.volatility
        puts "| #{t.pad(pad,1)} | #{datum.pad(pad,1)} | #{mov.average.pad(pad,1)} | #{mov.volatility.pad(pad,1)} | #{mov.variance.pad(pad,1)} | #{avg_diff >= 0 ? avg_diff.pad(pad,1).green : avg_diff.pad(pad,1).red } | #{vol_diff >= 0 ? vol_diff.pad(pad,1).green : vol_diff.pad(pad,1).red } | #{stage[t].pad(pad,1)} |"
      end
      return nil
    end

  end

  class Analyze
    include MovingAverage
    attr_accessor :dat_o, :heart, :accel
    def initialize(data_object)
      @dat_o = data_object
      @heart = data_object.heart
      @accel = data_object.accel
    end

    def rem?(t)
      mov = moving(t)
      mov.average > heart.average ? avg = true : avg = false
      mov.volatility > heart.volatility ? vol = true : vol = false
      mov.variance > heart.variance ? var = true : var = false
      vol && avg
    end

    def deep?(t)
      mov = moving(t)
      mov.average < heart.average ? avg = true : avg = false
      mov.volatility < heart.volatility ? vol = true : vol = false
      mov.variance < heart.variance ? var = true : var = false
      vol && avg
    end

    def medium?(t)
      mov = moving(t)
      mov.average.approx_equal?(heart.average) ? avg = true : avg = false
      mov.volatility.approx_equal?(heart.volatility) ? vol = true : vol = false
      mov.variance.approx_equal?(heart.variance) ? var = true : var = false
      vol && avg
    end

    def light?(t)
      mov = moving(t)
      mov.average > heart.average ? avg = true : avg = false
      mov.volatility.approx_equal?(heart.volatility) ? vol = true : vol = false
      mov.variance > heart.variance ? var = true : var = false
      vol && avg
    end

    # KEYS => 1: light, 2: medium, 3: deep, 4: REM
    def analyze
      stages = []
      heart.each_with_index do |datum, t|
        if rem?(t)
          stages << 40
        elsif deep?(t)
          stages << 30
        elsif medium?(t)
          stages << 20
        elsif light?(t)
          stages << 10
        else
          stages << 0
        end
      end
      @dat_o.stage = stages
      return @dat_o
    end

  end

end