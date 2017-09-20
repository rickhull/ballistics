require 'ballistics/ext'

module Ballistics
  DRAG_NUM = {}
  1.upto(8) { |g| DRAG_NUM["G#{g}"] = g }

  # e.g. Ballistics.trajectory(drag_function: 'G1',
  #                            ballistic_coefficient: 0.465,
  #                            velocity: 2200,
  #                            sight_height: 2.6,
  #                            zero_range: 100)
  #
  def self.trajectory(opts = {})
    opts[:shooting_angle] ||= 0
    opts[:wind_speed] ||= 0
    opts[:wind_angle] ||= 0
    opts[:max_range] ||= 500
    opts[:interval] ||= 25
    opts[:zero_angle] ||= self.zero_angle(opts)

    # order matters!
    args = [
      # ammo projectile characteristics
      :drag_function,     # e.g. G1
      :ballistic_coefficient,  # e.g. 0.5
      # ammo cartridge and barrel length determine muzzle velocity
      :velocity,          # feet per second, e.g. 2200
      # sight configuration relative to the bore
      :sight_height,      # inches, between sight and bore axes, e.g. 2.6
      # target location relative to shooter
      :shooting_angle,    # degrees, 0 for level, -90 for straight down
      # sight configuration relative to the bore
      :zero_angle,        # degrees, between sight and bore axes
      # environmental concerns
      :wind_speed,        # mph, e.g. 0
      :wind_angle,        # degrees, 0 headwind, 90 right-to-left
      # trajectory output table
      :max_range,         # yards, e.g. 500
      :interval,          # yards, e.g. 100
    ].map { |param| opts.fetch(param) }
    args[0] = DRAG_NUM.fetch(args[0].upcase)
    atm = opts[:atmosphere]
    args[1] = atm.translate(args[1]) if atm

    Ext.trajectory(*args)
  end

  # this is needed by trajectory()
  def self.zero_angle(opts = {})
    opts[:y_intercept] ||= 0      # how high the bullet impacts at zero_range

    args = [
      :drag_function,             # e.g. G1
      :ballistic_coefficient,     # e.g. 0.5
      :velocity,                  # muzzle velocity in FPS
      :sight_height,              # e.g. 2.6
      :zero_range,                # yards, e.g. 100
      :y_intercept,               # typically zero
    ].map { |param| opts.fetch(param) }
    args[0] = DRAG_NUM.fetch(args[0].upcase)
    atm = opts[:atmosphere]
    args[1] = atm.translate(args[1]) if atm

    Ext.zero_angle(*args)
  end

  def self.table(opts = {})
    items = {
      "Range" => "range",
      "Time" => "time",
      "FPS" => "velocity",
      "MOA" => "moa_correction",
    }
    trj = opts[:trajectory] || self.trajectory(opts)
    items.keys.join("\t") + "\n" +
      trj.map { |h| "%i\t%0.3f\t%0.1f\t%0.1f" % items.values.map { |i| h[i] }
    }.join("\n")
  end
end
