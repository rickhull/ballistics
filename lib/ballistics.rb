require 'ballistics/ext'

module Ballistics
  DRAG_NUM = {}
  1.upto(8) { |g| DRAG_NUM["G#{g}"] = g }

  def self.trajectory(opts = {})
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
    atm = opts[:atmosphere]
    args[1] = atm.translate(args[1]) if atm

    Ext.trajectory(*args)
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
    atm = opts[:atmosphere]
    args[1] = atm.translate(args[1]) if atm

    Ext.zero_angle(*args)
  end
end
