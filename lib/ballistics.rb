require 'ballistics/ballistics'
require_relative 'ballistics/trajectory'
require_relative 'ballistics/atmosphere'
require_relative 'ballistics/zero'

module Ballistics
  
  def self.build_environment(options = {})
    Ballistics::Atmosphere.new(options)
  end

  def self.map_trajectory(options = {})
    [:drag_function, :drag_coefficient, :velocity, :sight_height, :zero_range].each do |requirement|
      raise ArgumentError, "Failed to specify: #{requirement}" unless options[requirement]
    end

    # correct ballistic coefficient if an environment was passed
    options[:drag_coefficient] = options[:environment].correct_ballistic_coefficient(options[:drag_coefficient]) if options[:environment]

    options[:zero_angle] = Zero.calculate_zero_angle(options)
    Ballistics::Trajectory.map_trajectory(options)
  end

end

