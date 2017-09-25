require 'minitest/autorun'
require 'ballistics/problem'

include Ballistics

describe Problem do
  it "calculates the expected zero angle" do
    opts = {
      drag_number: 1,
      ballistic_coefficient: 0.5,
      velocity: 1200,
      sight_height: 1.6,
      zero_range: 100,
    }
    Problem.zero_angle(opts).round(6).must_equal 0.227188
  end

  describe "trajectory" do
    @problem = Problem.new(atmosphere: Atmosphere.new("altitude" => 5430,
                                                      "humidity" => 0.48,
                                                      "pressure" => 29.93,
                                                      "temp" => 40))
    @opts = {
      drag_number: 1,
      ballistic_coefficient: 0.5,
      velocity: 2850,
      sight_height: 1.6,
      wind_speed: 10,
      wind_angle: 90,
      zero_range: 200,
      max_range: 1000,
      interval: 25,
    }

    def self.trajectory
      @trajectory ||= @problem.trajectory(@opts)
    end

    it "raises with insufficient params" do
      proc { Problem.trajectory(drag_function: 'G1',
                                drag_number: 1,
                                ballistic_coefficient: 0.5,
                                velocity: 2850) }.must_raise Exception
    end

    it "has the expected range" do
      t = self.class.trajectory
      Hash[2 => 50,
           4 => 100,
           8 => 200,
           12 => 300,
           16 => 400,
           20 => 500,
           40 => 1000,
          ].each { |i, val|
        t[i]['range'].must_equal val
      }
    end

    it "has the expected path" do
      t = self.class.trajectory
      Hash[2 => 0.6,
           4 => 1.6,
           8 => 0,
           12 => -7,
           16 => -20.1,
           20 => -40.1,
           40 => -282.5,
          ].each { |i, val|
        t[i]['path'].round(1).must_equal val
      }
    end

    it "has the expected velocity" do
      t = self.class.trajectory
      Hash[2 => 2769,
           4 => 2691,
           8 => 2538,
           12 => 2390,
           16 => 2246,
           20 => 2108,
           40 => 1500,
          ].each { |i, val|
        t[i]['velocity'].to_i.must_equal val
      }
    end

    it "has the expected MOA correction" do
      t = self.class.trajectory
      Hash[2 => -1.1,
           4 => -1.5,
           8 => 0,
           12 => 2.2,
           16 => 4.8,
           20 => 7.7,
           40 => 27,
          ].each { |i, val|
        t[i]['moa_correction'].round(1).must_equal val
      }
    end

    it "has the expected windage" do
      t = self.class.trajectory
      Hash[2 => 0.2,
           4 => 0.6,
           8 => 2.3,
           12 => 5.2,
           16 => 9.4,
           20 => 15.2,
           40 => 71.3,
          ].each { |i, val|
        t[i]['windage'].round(1).must_equal val
      }
    end

    it "has the expected MOA correction for windage" do
      t = self.class.trajectory
      Hash[2 => 0.3,
           4 => 0.5,
           8 => 1.1,
           12 => 1.6,
           16 => 2.3,
           20 => 2.9,
           40 => 6.8,
          ].each { |i, val|
        t[i]['moa_windage'].round(1).must_equal val
      }
    end
  end
end
