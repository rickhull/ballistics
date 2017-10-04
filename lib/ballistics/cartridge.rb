require 'ballistics/yaml'

class Ballistics::Cartridge
  YAML_DIR = 'cartridges'

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

  # used to guesstimate muzzle velocities for unknown barrel lengths
  BURN_LENGTH = {
    '300 BLK' => 9,
    '5.56' => 20,
    '.223' => 20,
    '.308' => 24,
  }

  # 1% FPS gain/loss per inch of barrel length
  FPS_INCH_FACTOR = 0.01

  # Load a built-in YAML file and instantiate cartridge objects
  # Return a hash of cartridge objects keyed by the cartridge id as in the YAML
  #
  def self.find(file: nil, id: nil)
    Ballistics::YAML.find(klass: self, file: file, id: id)
  end

  # This is a helper method to perform loading of cartridges and projectiles
  # and to perform the cross ref.  This works only with built in cartridge and
  # projectile data.  To do this for user-supplied data files, the user should
  # perform the cross_ref explicitly
  #
  def self.find_with_projectiles(chamber)
    require 'ballistics/projectile'
    cartridges = self.find(file: chamber)
    projectiles = Ballistics::Projectile.find(file: chamber)
    self.cross_ref(cartridges, projectiles)
    cartridges
  end

  # A cartridge object starts with a string identifier for its projectile
  # Given a hash of cartridge objects (keyed by cartridge id)
  #   and a hash of projectile objects (keyed by projectile id)
  # Set the cartridge's projectile to the projectile object identified
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

  # Given a single data point (barrel_length, muzzle_velocity)
  #   and a known burn length
  # Guess a muzzle velocity for an unknown length
  #
  def self.guess_mv(known_length, known_mv, barrel_length, burn_length = nil)
    inch_diff = known_length - barrel_length
    burn_factor = self.burn_factor(burn_length, known_length, barrel_length)
    fps_per_inch = known_mv * burn_factor * FPS_INCH_FACTOR
    known_mv - inch_diff * fps_per_inch
  end

  # Given at least two data points (barrel_length, muzzle_velocity)
  # Estimate a muzzle velocity for an unknown length assuming the relationship
  #   between barrel length and muzzle velocity is linear
  def self.estimate_mv(known_mvs, barrel_length, burn_length = nil)
    if !known_mvs.is_a?(Hash) or known_mvs.empty?
      raise(TypeError, "populated Hash expected")
    end
    if known_mvs.length == 1
      return self.guess_mv(known_mvs.keys.first,
                           known_mvs.values.first,
                           burn_length,
                           barrel_length)
    end
    known_lengths = known_mvs.keys.sort
    lb = known_lengths.first
    ub = known_lengths.last
    if lb < barrel_length and barrel_length < ub
      # we can interpolate
      known_lengths.each { |len|
        if barrel_length < len
          ub = len
          break
        end
        lb = len
      }
    else
      # we must extrapolate
      if barrel_length < lb
        lb, ub = known_lengths[0], known_lengths[1]
      else
        lb, ub = known_lengths[-2], known_lengths[-1]
      end
    end
    lv, uv = known_mvs.fetch(lb), known_mvs.fetch(ub)

    # TODO: consider adjusting m by burn_factor()
    m, b = self.linear_coefficients(lb, ub, lv, uv)
    m * barrel_length + b
  end

  # muzzle velocity curve is steeper below burn length and shallower above it
  # the burn_factor can correct a linear prediction if we know the burn length
  # take the average of the known and unknown
  def self.burn_factor(burn_length, known_length, barrel_length)
    return 1 unless burn_length
    (burn_length.to_f / known_length + burn_length.to_f / barrel_length) / 2
  end

  # Assume: y = mx + b
  # Given 2 points, return m and b
  #
  def self.linear_coefficients(x1, x2, y1, y2)
    m = (y1 - y2) / (x1 - x2)
    b = y1 - m * x1
    [m, b]
  end

  # Match and extract e.g. "16" from "16_inch_fps"
  BARREL_LENGTH_REGEX = /([0-9]+)_inch_fps/i

  attr_reader(*MANDATORY.keys)
  attr_reader(*OPTIONAL.keys)
  attr_reader :muzzle_velocity, :yaml_data, :extra
  attr_writer :projectile

  def initialize(hsh)
    @yaml_data = hsh
    MANDATORY.each { |field, type|
      val = hsh.fetch(field)
      val = val.to_s if field == "case" and type == :string
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
  def mv(barrel_length, burn_length = nil)
    # is MV already known?
    [barrel_length, barrel_length.floor, barrel_length.ceil].each { |candidate|
      mv = @muzzle_velocity[candidate]
      return mv if mv
    }
    self.class.estimate_mv(@muzzle_velocity, barrel_length, BURN_LENGTH[@case])
  end

  def multiline
    lines = ["CARTRIDGE: #{@name}", "========="]
    fields = {
      "Case" => @case,
    }
    @muzzle_velocity.keys.sort.each { |bar_len|
      fields["MV @ #{bar_len}"] = @muzzle_velocity[bar_len]
    }
    fields["Desc"] = @desc if @desc
    fields.each { |name, val|
      lines << [name.rjust(9, ' '), val].join(': ')
    }
    lines.join("\n")
  end
end
