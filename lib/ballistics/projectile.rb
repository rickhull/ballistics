require 'ballistics/yaml'

class Ballistics::Projectile
  MANDATORY = {
    "name"   => :string,
    "cal"    => :float,
    "grains" => :count,
  }
  BALLISTIC_COEFFICIENT = {
    "g1" => :float,
    "g7" => :float,
  }
  OPTIONAL = {
    "sd"       => :float,
    "intended" => :string,
    "base"     =>:string,
    "desc"     => :string,
  }

  def self.load(filename)
    objects = {}
    Ballistics.load_yaml(filename, 'projectiles').each { |id, hsh|
      objects[id] = self.new(hsh)
    }
    objects
  end

  def self.base(candidate)
    c = candidate.to_s.downcase
    case c
    when "flat", "boat"
      c
    when "boattail"
      "boat"
    when "flatbase", "flat base"
      "flat"
    else
      raise "unknown base: #{candidate}"
    end
  end

  attr_reader *MANDATORY.keys
  attr_reader *BALLISTIC_COEFFICIENT.keys
  attr_reader *OPTIONAL.keys
  attr_reader :ballistic_coefficient, :yaml_data, :extra

  def initialize(hsh)
    @yaml_data = hsh
    MANDATORY.each { |field, type|
      val = hsh.fetch(field)
      Ballistics.check_type!(val, type)
      self.instance_variable_set("@#{field}", val)
    }
    @ballistic_coefficient = {}
    BALLISTIC_COEFFICIENT.each { |field, type|
      if hsh.key?(field)
        val = hsh[field]
        Ballistics.check_type!(val, type)
        self.instance_variable_set("@#{field}", val)
        @ballistic_coefficient[field] = val
      end
    }
    raise "no valid BC" if @ballistic_coefficient.empty?

    OPTIONAL.each { |field, type|
      if hsh.key?(field)
        val = hsh[field]
        Ballistics.check_type!(val, type)
        if field == "base"
          @base = self.class.base(val)
        else
          self.instance_variable_set("@#{field}", val)
        end
      end
    }
    @extra = {}
    (hsh.keys - MANDATORY.keys - BALLISTIC_COEFFICIENT.keys - OPTIONAL.keys).each { |k| @extra[k] = hsh[k] }
  end
end
