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
  DRAG_FUNCTION = {
    "flat" => "g1",
    "boat" => "g7",
  }

  # Load a YAML file and instantiate projectile objects
  # Return a hash of projectile objects keyed by projectile id (per the YAML)
  #
  def self.built_in_objects(short_name)
    objects = {}
    Ballistics::YAML.load_built_in('projectiles', short_name).each { |id, hsh|
      objects[id] = self.new(hsh)
    }
    objects
  end

  # Normalize common flat-base and boat-tail terms to flat or boat
  #
  def self.base(candidate)
    c = candidate.to_s.downcase.gsub(/[\-\_ ]/, '')
    case c
    when "boat", "boattail", "bt"
      "boat"
    when "flat", "flatbase", "fb"
      "flat"
    else
      raise "unknown base: #{candidate}"
    end
  end

  attr_reader(*MANDATORY.keys)
  attr_reader(*BALLISTIC_COEFFICIENT.keys)
  attr_reader(*OPTIONAL.keys)
  attr_reader :ballistic_coefficient, :yaml_data, :extra

  def initialize(hsh)
    @yaml_data = hsh
    MANDATORY.each { |field, type|
      val = hsh.fetch(field)
      Ballistics::YAML.check_type!(val, type)
      self.instance_variable_set("@#{field}", val)
    }

    # Extract ballistic coefficients per drag model (e.g. G1)
    # We need at least one
    #
    @ballistic_coefficient = {}
    BALLISTIC_COEFFICIENT.each { |field, type|
      if hsh.key?(field)
        val = hsh[field]
        Ballistics::YAML.check_type!(val, type)
        self.instance_variable_set("@#{field}", val)
        @ballistic_coefficient[field] = val
      end
    }
    raise "no valid BC" if @ballistic_coefficient.empty?

    OPTIONAL.each { |field, type|
      if hsh.key?(field)
        val = hsh[field]
        Ballistics::YAML.check_type!(val, type)
        if field == "base"
          @base = self.class.base(val)
        else
          self.instance_variable_set("@#{field}", val)
        end
      end
    }

    # Keep track of fields that we don't expect
    @extra = {}
    (hsh.keys -
     MANDATORY.keys -
     BALLISTIC_COEFFICIENT.keys -
     OPTIONAL.keys).each { |k| @extra[k] = hsh[k] }
  end

  # return the preferred drag function if there is a BC available
  def drag_function
    preferred = DRAG_FUNCTION.fetch(@base)
    return preferred if @ballistic_coefficient.key?(preferred)
    @ballistic_coefficient.keys.first
  end

  # return the BC for the preferred drag function
  def bc
    @ballistic_coefficient[self.drag_function]
  end
end
