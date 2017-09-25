require 'ballistics/ext'

module Ballistics
  def self.zero_angle(opts = {})
    opts[:y_intercept] ||= 0
    args = [
      :drag_number,
      :ballistic_coefficient,
      :velocity,
      :sight_height,
      :zero_range,
      :y_intercept,
    ].map { |arg| opts.fetch(arg) }

    Ballistics::Ext.zero_angle(*args)
  end

  def self.trajectory(opts = {})
    opts[:zero_angle] ||= self.zero_angle(opts)
    args = [
      :drag_number,
      :ballistic_coefficient,
      :velocity,
      :sight_height,
      :shooting_angle,
      :zero_angle,
      :wind_speed,
      :wind_angle,
      :max_range,
      :interval,
    ].map { |arg| opts.fetch(arg) }

    Ballistics::Ext.trajectory(*args)
  end

  def self.table(opts = {})
    trj = opts[:trajectory] || self.trajectory(opts)
    items = {
      "Range" => "range",
      "Time" => "time",
      "FPS" => "velocity",
      "MOA" => "moa_correction",
    }
    items.keys.join("\t") + "\n" +
      trj.map { |h| "%i\t%0.3f\t%0.1f\t%0.1f" % items.values.map { |i| h[i] }
    }.join("\n")
  end
end
