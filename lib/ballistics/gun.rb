require 'ballistics/yaml'

class Ballistics::Gun
  MANDATORY = {
    "name" => :string,
    "chamber" => :string,
    "barrel_length" => :float,
    "sight_height" => :float,
  }
  OPTIONAL = {
    "zero_range" => :float,
  }

  # map a chamber name to a built-in cartridge YAML filename
  CHAMBER_CARTRIDGE = {
    '5.56' => '5_56',
    '300 BLK' => '300_blk'
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
  attr_reader(:cartridge_file, :yaml_data, :extra)

  def initialize(hsh)
    @yaml_data = hsh
    MANDATORY.each { |field, type|
      val = hsh.fetch(field)
      if field == "chamber"
        val = val.to_s
        @cartridge_file = CHAMBER_CARTRIDGE.fetch(val)
      end
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

  # this will pull in cartridges and projectiles based on the gun chamber
  def cartridges
    require 'ballistics/cartridge'

    Ballistics::Cartridge.load_projectiles(@cartridge_file)
  end
end
