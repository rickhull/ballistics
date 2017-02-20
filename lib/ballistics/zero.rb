require_relative 'df_map'

module Ballistics
  module Zero
    def self.calculate_zero_angle(opts = {})
      options = { y_intercept: 0 }.merge(opts)

      drag_function = Ballistics::DFMap.__convert_df_to_int(options[:drag_function])
      drag_coefficient = options[:drag_coefficient]
      vi = options[:velocity]
      sight_height = options[:sight_height]
      zero_range = options[:zero_range]
      y_intercept = options[:y_intercept]

      self._calculate_zero_angle(drag_function, drag_coefficient, vi, sight_height, zero_range, y_intercept)
    end
  end
end
