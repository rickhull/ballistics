require 'bigdecimal'
require 'bigdecimal/util'

module Ballistics
  class Atmosphere
    STANDARD_TEMPERATURE = 59.to_d
    STANDARD_PRESSURE = 29.53.to_d
    STANDARD_HUMIDITY = 0.78.to_d
    STANDARD_ALTITUDE = 0.to_d
    RANKLINE_CORRECTION = 459.4.to_d

    attr_accessor :altitude, :barometric_pressure, :temperature, :relative_humidity

    def initialize(options = {})
      @altitude = options[:altitude].to_d
      @barometric_pressure = options[:barometric_pressure].to_d
      @temperature = options[:temperature].to_d
      @relative_humidity = options[:relative_humidity].to_d
    end

    def correct_ballistic_coefficient(ballistic_coefficient)
      ballistic_coefficient = ballistic_coefficient.to_d
      corrected_ballistic_coefficient = (altitude_factor * (1 + temperature_factor - pressure_factor) * humidity_factor)
      return ballistic_coefficient * corrected_ballistic_coefficient
    end

    private

    def humidity_factor
      vpw = 4e-6.to_d * @temperature**3 - 0.0004.to_d * @temperature**2.to_d + 0.0234.to_d * @temperature - 0.2517.to_d 
      frh = 0.995.to_d * (@barometric_pressure / (@barometric_pressure - 0.3783.to_d * @relative_humidity * vpw) )
      return frh
    end

    def pressure_factor
      pressure_correction_factor = (@barometric_pressure - STANDARD_PRESSURE) / STANDARD_PRESSURE
      return pressure_correction_factor
    end

    def temperature_factor
      standard_temp_for_altitude = -0.0036.to_d * @altitude + STANDARD_TEMPERATURE
      temp_correction_factor = (@temperature - standard_temp_for_altitude) / (RANKLINE_CORRECTION + standard_temp_for_altitude)
      return temp_correction_factor
    end

    def altitude_factor
      altitude_correction_factor = -4e-15.to_d * @altitude**3 + 4e-10.to_d * @altitude**2 - 3e-5.to_d * @altitude + 1
      return 1 / altitude_correction_factor
    end
  end
end
