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
  def self.find(short_name)
    objects = {}
    Ballistics::YAML.load_built_in('guns', short_name).each { |id, hsh|
      obj = self.new(hsh)
      if block_given?
        objects[id] = obj if yield obj
      else
        objects[id] = obj
      end
    }
    objects
  end

  def self.find_id(id)
    Ballistics::YAML::BUILT_IN.fetch('guns').each { |short_name|
      object = self.find(short_name)[id]
      return object if object
    }
    nil
  end

  def self.fetch_id(id)
    self.find_id(id) or raise("id #{id} not found")
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
    @cartridges = []
  end

  def chamber=(new_chamber)
    @cartridges = []
    @chamber = new_chamber
  end

  def cartridge_file
    CHAMBER_CARTRIDGE[@chamber] or raise(ChamberNotFound, @chamber)
  end

  # this will pull in cartridges and projectiles based on the gun chamber
  def cartridges
    if @cartridges.empty?
      require 'ballistics/cartridge'

      cartridge_file = CHAMBER_CARTRIDGE[@chamber] or
        raise(ChamberNotFound, @chamber)
      @cartridges =
        Ballistics::Cartridge.find_with_projectiles(cartridge_file)
    end
    @cartridges
  end

  def params
    params = {
      sight_height: self.sight_height
    }
    params[:zero_range] = self.zero_range if self.zero_range
    params
  end
end
