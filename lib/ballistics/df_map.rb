module Ballistics
  module DFMap
    def self.__convert_df_to_int(drag_function)
      case drag_function
      when 'G1' then 1
      when 'G2' then 2
      when 'G3' then 3
      when 'G4' then 4
      when 'G5' then 5
      when 'G6' then 6
      when 'G7' then 7
      when 'G8' then 8
      end
    end
  end
end
