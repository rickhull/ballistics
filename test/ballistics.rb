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
    Ballistics.zero_angle(opts).round(6).must_equal 0.227188
  end
end
