require 'ballistics/yaml'

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

  # Load a YAML file and instantiate cartridge objects
  # Return a hash of cartridge objects keyed by the cartridge id as in the YAML
  #
  def self.load(filename)
    objects = {}
    Ballistics.load_yaml(filename, 'cartridges').each { |id, hsh|
      objects[id] = self.new(hsh)
    }
    objects
  end

  # This is a helper method to perform loading of cartridges and projectiles
  # and to perform the cross ref.  This works only with built in cartridge and
  # projectile data.  To do this for user-supplied data files, the user should
  # perform the cross_ref explicitly
  #
  def self.load_projectiles(chamber)
    require 'ballistics/projectile'

    cartridges = self.load(chamber)
    projectiles = Ballistics::Projectile.load(chamber)
    self.cross_ref(cartridges, projectiles)
    cartridges
  end

  # A cartridge object starts with a string identifier for its projectile
  # Given a hash of cartridge objects (keyed by cartridge id)
  #   and a hash of projectile objects (keyed by projectile id)
  #   Set the cartridge's projectile to the projectile object identified
  #   by the string value
  # The cartridge objects in the cartridges hash are updated in place
  # The return value reports what was updated
  #
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

  # match and extract e.g. "16" from "16_inch_fps"
  BARREL_LENGTH_REGEX = /([0-9]+)_inch_fps/i

  attr_reader(*MANDATORY.keys)
  attr_reader(*OPTIONAL.keys)
  attr_reader :muzzle_velocity, :yaml_data, :extra
  attr_writer :projectile

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
    (hsh.keys - MANDATORY.keys - OPTIONAL.keys).each { |k| @extra[k] = hsh[k] }

    # Extract muzzle velocities per barrel length and remove from @extra
    # We need at least one
    #
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
    raise "no valid muzzle velocity" if @muzzle_velocity.empty?
  end

  # estimate muzzle velocity for a given barrel length
  def mv(barrel_length)
    [barrel_length, barrel_length.floor, barrel_length.ceil].each { |candidate|
      mv = @muzzle_velocity[candidate]
      return mv if mv
    }

    # ok, now we need to interpolate if we can
    raise "not implemented yet"
  end
end
