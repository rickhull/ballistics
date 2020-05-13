require 'minitest/autorun'
require 'ballistics'

describe Ballistics do
  it "calculates the expected zero angle" do
    opts = {
      drag_number: 1,
      ballistic_coefficient: 0.5,
      velocity: 1200,
      sight_height: 1.6,
      zero_range: 100,
    }
    expect(Ballistics.zero_angle(opts).round(6)).must_equal 0.227188
  end

  it "calculates the expected trajectory" do
    opts = {
      drag_number: 1,
      ballistic_coefficient: 0.5,
      velocity: 2250,
      sight_height: 2.6,
      zero_range: 50,
      wind_speed: 10,
      wind_angle: 90,
      max_range: 1000,
      interval: 25,
      shooting_angle: 0,
    }
    expect(Ballistics.trajectory(opts)).must_be_kind_of Array
  end
end
