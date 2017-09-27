require 'ballistics/ext'

module Ballistics
  TABLE_FIELDS = {
    range: {
      label: "Range",
      format: "%i",
    },
    time: {
      label: "Time",
      format: "%0.3f",
    },
    velocity: {
      label: "FPS",
      format: "%0.1f",
    },
    moa_correction: {
      label: "MOA",
      format: "%0.1f",
    },
    path: {
      label: "Path",
      format: "%0.1f",
    },
  }

  def self.table(trajectory: nil, fields: nil, opts: {})
    trj = trajectory || self.trajectory(opts)
    fields ||= [:range, :time, :velocity, :path]

    # Create an array of field labels and format strings once
    labels = []
    formats = []
    fields.each { |sym|
      cfg = TABLE_FIELDS.fetch(sym)
      labels << cfg.fetch(:label)
      formats << cfg.fetch(:format)
    }

    # Iterate over trajectory structure and return a multiline string
    labels.join("\t") + "\n" + trj.map { |hsh|
      formats.join("\t") % fields.map { |sym| hsh.fetch(sym.to_s) }
    }.join("\n")
  end

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
end
