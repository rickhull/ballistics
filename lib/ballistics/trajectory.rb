require_relative 'df_map'

module Ballistics
  module Trajectory
    def self.map_trajectory(opts = {})
      options = { shooting_angle: 0, wind_speed: 0, wind_angle: 0, max_range: 500, interval: 1 }.merge(opts)

      drag_function = Ballistics::DFMap.__convert_df_to_int(options[:drag_function])
      drag_coefficient = options[:drag_coefficient]
      vi = options[:velocity]
      sight_height = options[:sight_height]
      shooting_angle = options[:shooting_angle]
      z_angle = options[:zero_angle]
      wind_speed = options[:wind_speed]
      wind_angle = options[:wind_angle]
      max_range = options[:max_range]
      interval = options[:interval]

      self._map_trajectory(drag_function, drag_coefficient, vi, sight_height, shooting_angle, z_angle, wind_speed, wind_angle, max_range, interval)
    end
  end
end
