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
  def self.find(file: nil, id: nil)
    objects = {}
    if file
      candidates = Ballistics::YAML.load_built_in('guns', file)
    else
      candidates = {}
      Ballistics::YAML::BUILT_IN.fetch('guns').each { |f|
        candidates.merge!(Ballistics::YAML.load_built_in('guns', f))
      }
    end
    if id
      self.new candidates.fetch id
    else
      candidates.each { |cid, hsh|
        obj = self.new hsh
        if block_given?
          objects[cid] = obj if yield obj
        else
          objects[cid] = obj
        end
      }
      objects
    end
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
    params = { sight_height: @sight_height }
    params[:zero_range] = @zero_range if @zero_range
    params
  end

  def multiline
    lines = ["GUN: #{name}", "==="]
    fields = {
      "Chamber" => @chamber,
      "Barrel length" => @barrel_length,
      "Sight height" => @sight_height,
    }
    fields["Zero Range"] = @zero_range if @zero_range
    fields.each { |name, val|
      lines << [name.rjust(13, ' ' ), val].join(': ')
    }
    lines.join("\n")
  end
end
