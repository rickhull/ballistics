require 'ballistics/yaml'
# require 'ballistics/projectile'

class Ballistics::Cartridge
  MANDATORY = {
    "name" => :string,
    "case" => :string,
    "projectile" => :reference,
  }
  OPTIONAL = {
    "desc" => :string,
    "powder_grains" => :float,
    "powder_type" => :string,
  }

  def self.load(filename)
    objects = {}
    Ballistics.load_yaml(filename, 'cartridges').each { |id, hsh|
      objects[id] = self.new(hsh)
    }
    objects
  end

  def self.load_projectiles(chamber)
    require 'ballistics/projectile'

    cartridges = self.load(chamber)
    projectiles = Ballistics::Projectile.load(chamber)
    self.cross_ref(cartridges, projectiles)
    cartridges
  end

  def self.cross_ref(cartridges, projectiles)
    retval = {}
    cartridges.values.each { |c|
      if c.projectile.is_a?(String)
        proj_id = c.projectile
        proj = projectiles[proj_id]
        if proj
          c.projectile = proj
          retval[:updated] ||= []
          retval[:updated] << proj_id
        else
          warn "#{proj_id} not found in projectiles"
        end
      else
        warn "c.projectile is not a string"
      end
    }
    retval
  end

  BARREL_LENGTH_REGEX = /([0-9]+)_inch_fps/i

  attr_reader *MANDATORY.keys
  attr_reader *OPTIONAL.keys
  attr_reader :muzzle_velocity, :yaml, :extra
  attr_writer :projectile

  def initialize(hsh)
    @yaml = hsh
    MANDATORY.each { |name, type|
      val = hsh.fetch(name)
      Ballistics.check_type!(val, type)
      self.instance_variable_set("@#{name}", val)
    }
    OPTIONAL.each { |name, type|
      if hsh.key?(name)
        val = hsh[name]
        Ballistics.check_type!(val, type)
        self.instance_variable_set("@#{name}", val)
      end
    }
    @extra = {}
    (hsh.keys - MANDATORY.keys - OPTIONAL.keys).each { |k| @extra[k] = hsh[k] }

    # extract muzzle velocities per barrel length
    @muzzle_velocity = {}
    extracted = []
    @extra.each { |key, val|
      matches = key.match(BARREL_LENGTH_REGEX)
      if matches
        bl = matches[1].to_f.round
        @muzzle_velocity[bl] = val
        extracted << key
      end
    }
    extracted.each { |k| @extra.delete(k) }
  end
end
