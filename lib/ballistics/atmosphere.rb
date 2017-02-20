require 'bigdecimal'
require 'bigdecimal/util'

module Ballistics
  class Atmosphere
    # US Army standard, used by most commercial ammunition
    ARMY = {
      altitude: 0.to_d,       # feet
      humidity: 0.78.to_d,    # percent
      pressure: 29.5275.to_d, # inches of mercury
      temp: 59.to_d,          # degrees fahrenheit
    }

    # International Civil Aviation Organization
    ICAO = {
      altitude: 0.to_d,
      humidity: 0.to_d,
      pressure: 29.9213.to_d,
      temp: 59.to_d,
    }

    # coefficients
    ALTITUDE_A = -4e-15.to_d
    ALTITUDE_B = 4e-10.to_d
    ALTITUDE_C = -3e-5.to_d
    ALTITUDE_D = 1.to_d

    # coefficients
    HUMIDITY_A = 4e-6.to_d
    HUMIDITY_B = -0.0004.to_d
    HUMIDITY_C = 0.0234.to_d
    HUMIDITY_D = -0.2517.to_d

    RANKLINE_CORRECTION = 459.4.to_d
    TEMP_ALTITUDE_CORRECTION = -0.0036.to_d # degrees per foot

    attr_reader ARMY.keys

    def initialize(opts = {})
      opts = ARMY.merge(opts)
      @altitude = opts[:altitude].to_d
      @humidity = opts[:humidity].to_d
      @pressure = opts[:pressure].to_d
      @temp = opts[:temp].to_d
    end

    def altitude_factor
      1 / (ALTITUDE_A * @altitude ** 3 +
           ALTITUDE_B * @altitude ** 2 +
           ALTITUDE_C * @altitude      +
           ALTITUDE_D)
    end

    def humidity_factor
      vpw = HUMIDITY_A * @temp ** 3 +
            HUMIDITY_B * @temp ** 2 +
            HUMIDITY_C * @temp      +
            HUMIDITY_D
      0.995.to_d * @pressure / (@pressure - 0.3783.to_d * @humidity * vpw)
    end

    def pressure_factor
      (@pressure - ARMY[:pressure]) / ARMY[:pressure]
    end

    def temp_factor
      std_temp = ARMY[:temp] + @altitude * TEMP_ALTITUDE_CORRECTION
      (@temp - std_temp) / (RANKLINE_CORRECTION + std_temp)
    end

    def translate(ballistic_coefficient)
      ballistic_coefficient.to_d *
        self.altitude_factor *
        self.humidity_factor *
        (1 + self.temp_factor - self.pressure_factor)
    end
  end
end
