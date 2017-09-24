require 'bigdecimal'
require 'bigdecimal/util'
require 'ballistics/yaml'

# http://www.exteriorballistics.com/ebexplained/4th/51.cfm

class Ballistics::Atmosphere
  MANDATORY = {
    "altitude" => :float,   # feet
    "humidity" => :percent, # float between 0 and 1
    "pressure" => :float,   # inches of mercury
    "temp"     => :float,   # degrees fahrenheit
  }

  # US Army standard, used by most commercial ammunition specs
  ARMY = {
    "altitude" => 0,
    "humidity" => 0.78,
    "pressure" => 29.5275,
    "temp"     => 59,
  }

  # International Civil Aviation Organization
  ICAO = {
    "altitude" => 0,
    "humidity" => 0,
    "pressure" => 29.9213,
    "temp"     => 59,
  }

  # altitude coefficients
  ALTITUDE_A = -4e-15.to_d
  ALTITUDE_B = 4e-10.to_d
  ALTITUDE_C = -3e-5.to_d
  ALTITUDE_D = 1.to_d

  # humidity coefficients
  VAPOR_A = 4e-6.to_d
  VAPOR_B = -0.0004.to_d
  VAPOR_C = 0.0234.to_d
  VAPOR_D = -0.2517.to_d

  DRY_AIR_INCREASE  = 0.3783.to_d
  DRY_AIR_REDUCTION = 0.9950.to_d
  RANKLINE_CORRECTION = 459.4.to_d
  TEMP_ALTITUDE_CORRECTION = -0.0036.to_d # degrees per foot

  def self.altitude_factor(altitude)
    altitude = altitude.to_d
    1 / (ALTITUDE_A * altitude ** 3 +
         ALTITUDE_B * altitude ** 2 +
         ALTITUDE_C * altitude      +
         ALTITUDE_D)
  end

  def self.humidity_factor(temp, pressure, humidity)
    vpw = VAPOR_A * temp ** 3 +
          VAPOR_B * temp ** 2 +
          VAPOR_C * temp      +
          VAPOR_D
    DRY_AIR_REDUCTION * pressure /
      (pressure - DRY_AIR_INCREASE * humidity * vpw)
  end

  def self.pressure_factor(pressure)
    pressure = pressure.to_d
    (pressure - ARMY["pressure"]) / ARMY["pressure"]
  end

  def self.temp_factor(temp, altitude)
    std_temp = ARMY["temp"] + altitude * TEMP_ALTITUDE_CORRECTION
    (temp - std_temp) / (RANKLINE_CORRECTION + std_temp)
  end

  attr_reader(*MANDATORY.keys)
  attr_reader(:yaml_data, :extra)

  def initialize(hsh = ARMY.dup)
    @yaml_data = hsh
    MANDATORY.each { |field, type|
      val = hsh[field] || hsh[field.to_sym] or raise("#{field} not provided")
      Ballistics::YAML.check_type!(val, type)
      self.instance_variable_set("@#{field}", val.to_d)
    }
  end

  def translate(ballistic_coefficient)
    ballistic_coefficient.to_d *
      self.class.altitude_factor(@altitude) *
      self.class.humidity_factor(@temp, @pressure, @humidity) *
      (self.class.temp_factor(@temp, @altitude) -
       self.class.pressure_factor(@pressure) + 1)
  end
end
