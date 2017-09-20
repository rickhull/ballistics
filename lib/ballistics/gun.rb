require 'ballistics/yaml'

class Ballistics::Gun
  MANDATORY = {
    "sight_height" => :float,
    "barrel_length" => :float,
  }
  OPTIONAL = {
    "zero_range" => :float,
  }

  # Load a YAML file and instantiate gun objects
  # Return a hash of gun objects keyed by gun id (per the YAML)
  #
  def self.load(filename)
    objects = {}
    Ballistics.load_yaml(filename, 'guns').each { |id, hsh|
      objects[id] = self.new(hsh)
    }
    objects
  end

  attr_reader(*MANDATORY.keys)
  attr_reader(*OPTIONAL.keys)
  attr_reader(:yaml_data, :extra)

  def initialize(hsh)
    @yaml_data = hsh
    MANDATORY.each { |field, type|
      val = hsh.fetch(field)
      Ballistics.check_type!(val, type)
      self.instance_variable_set("@#{field}", val)
    }

    OPTIONAL.each { |field, type|
      if hsh.key?(field)
        val = hsh[field]
        Ballistics.check_type!(val, type)
        self.instance_variable_set("@#{field}", val)
      end
    }

    # Keep track of fields that we don't expect
    @extra = {}
    (hsh.keys - MANDATORY.keys - OPTIONAL.keys).each { |k|
      @extra[k] = hsh[k]
    }
  end
end
