require 'ballistics/ballistics'
require 'ballistics/atmosphere'

module Ballistics
  DRAG_NUM = {}
  1.upto(8) { |g| DRAG_NUM["G#{g}"] = g }

  def self.trajectory(opts = {})
    env = opts[:environment] # optional, possibly nil

    opts[:shooting_angle] ||= 0
    opts[:wind_speed] ||= 0
    opts[:wind_angle] ||= 0
    opts[:max_range] ||= 500
    opts[:interval] ||= 1
    opts[:zero_angle] ||= self.zero_angle(opts)


    args = [
      :drag_function,
      :drag_coefficient,
      :velocity,
      :sight_height,
      :shooting_angle,
      :zero_angle,
      :wind_speed,
      :wind_angle,
      :max_range,
      :interval,
    ].map { |param| opts.fetch(param) }
    args[0] = DRAG_NUM.fetch(args[0])
    args[1] = env.correct_ballistic_coefficient(args[1]) if env

    self._map_trajectory(*args)
  end

  def self.zero_angle(opts = {})
    opts[:y_intercept] ||= 0

    args = [
      :drag_function,
      :drag_coefficient,
      :velocity,
      :sight_height,
      :zero_range,
      :y_intercept,
    ].map { |param| opts.fetch(param) }
    args[0] = DRAG_NUM.fetch(args[0])

    self._calculate_zero_angle(*args)
  end

  def self.build_environment(options = {})
    Ballistics::Atmosphere.new(options)
  end
end
