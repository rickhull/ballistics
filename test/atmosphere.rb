require 'minitest/autorun'
require 'ballistics/atmosphere'

include Ballistics

describe Atmosphere do
  before do
    @altitude = 5430
    @humidity = 0.48
    @pressure = 29.93
    @temp = 40
  end

  it "translates a ballistic coefficient" do
    Atmosphere.translate(0.338,
                         altitude: @altitude,
                         humidity: @humidity,
                         pressure: @pressure,
                         temp: @temp).round(3).must_equal 0.392

    Atmosphere.new("altitude" => @altitude,
                   "humidity" => @humidity,
                   "pressure" => @pressure,
                   "temp" => @temp).translate(0.338).round(3).must_equal 0.392
  end
end
