require 'ballistics/yaml'
# require 'ballistics/projectile'

class Ballistics::Cartridge
  MANDATORY = {
    "name" => :string,
    "case" => :string,
    "projectile" => :reference,
  }
  MUZZLE_VELOCITY = {
    "16_inch_fps" => :count,
    "20_inch_fps" => :count,
    "24_inch_fps" => :count,
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
        end
      else
        warn "c.projectile is not a string"
      end
    }
    retval
  end

  def self.barrel_length(mv_name)
    matches = mv_name.match /([0-9.]+)_inch_fps/i
    matches[1] or raise("can't determine barrel length from: #{mv_name}")
  end

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
    @muzzle_velocity = {}
    MUZZLE_VELOCITY.each { |name, type|
      if hsh.key?(name)
        val = hsh[name]
        barrel = self.class.barrel_length(name)
        Ballistics.check_type!(val, type)
        @muzzle_velocity[barrel] = val
      end
    }
    raise "muzzle velocity required" if @muzzle_velocity.empty?
    OPTIONAL.each { |name, type|
      if hsh.key?(name)
        val = hsh[name]
        Ballistics.check_type!(val, type)
        self.instance_variable_set("@#{name}", val)
      end
    }
    @extra = {}
    (hsh.keys - MANDATORY.keys - OPTIONAL.keys).each { |k| @extra[k] = hsh[k] }
  end
end
