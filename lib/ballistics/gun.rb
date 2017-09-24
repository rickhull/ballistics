require 'ballistics/yaml'

class Ballistics::Gun
  class ChamberNotFound < KeyError; end

  MANDATORY = {
    "name"          => :string,
    "chamber"       => :string,
    "barrel_length" => :float,
    "sight_height"  => :float,
  }
  OPTIONAL = {
    "zero_range" => :float,
  }

  # map a chamber name to a built-in cartridge YAML filename
  CHAMBER_CARTRIDGE = {
    '5.56' => '5_56',
    '300 BLK' => '300_blk',
    # TODO: create these cartridge yamls
    # '.45 ACP' => '45_acp',
    # '12ga' => '12ga',
  }

  # Load a built-in YAML file and instantiate gun objects
  # Return a hash of gun objects keyed by gun id (per the YAML)
  #
  def self.built_in_objects(short_name)
    objects = {}
    Ballistics::YAML.load_built_in('guns', short_name).each { |id, hsh|
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
      val = val.to_s if field == "chamber"
      Ballistics::YAML.check_type!(val, type)
      self.instance_variable_set("@#{field}", val)
    }

    OPTIONAL.each { |field, type|
      if hsh.key?(field)
        val = hsh[field]
        Ballistics::YAML.check_type!(val, type)
        self.instance_variable_set("@#{field}", val)
      end
    }

    # Keep track of fields that we don't expect
    @extra = {}
    (hsh.keys - MANDATORY.keys - OPTIONAL.keys).each { |k|
      @extra[k] = hsh[k]
    }
  end

  def cartridge_file
    CHAMBER_CARTRIDGE[@chamber] or raise(ChamberNotFound, @chamber)
  end

  # this will pull in cartridges and projectiles based on the gun chamber
  def cartridges
    require 'ballistics/cartridge'

    Ballistics::Cartridge.load_projectiles(self.cartridge_file)
  end
end
