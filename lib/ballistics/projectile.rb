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

  def self.load(filename)
    objects = {}
    Ballistics.load_yaml(filename, 'projectiles').each { |id, hsh|
      objects[id] = self.new(hsh)
    }
    objects
  end

  def self.base(candidate)
    c = candidate.to_s.downcase
    case c
    when "flat", "boat"
      c
    when "boattail"
      "boat"
    when "flatbase", "flat base"
      "flat"
    else
      raise "unknown base: #{candidate}"
    end
  end

  attr_reader *MANDATORY.keys
  attr_reader *BALLISTIC_COEFFICIENT.keys
  attr_reader *OPTIONAL.keys
  attr_reader :yaml

  def initialize(hsh)
    @yaml = hsh
    MANDATORY.each { |name, type|
      val = hsh.fetch(name)
      Ballistics.check_type!(val, type)
      self.instance_variable_set("@#{name}", val)
    }
    bc_ok = false
    BALLISTIC_COEFFICIENT.each { |name, type|
      if hsh.key?(name)
        val = hsh[name]
        Ballistics.check_type!(val, type)
        self.instance_variable_set("@#{name}", val)
        bc_ok = true
      end
    }
    raise "no valid BC" unless bc_ok
    OPTIONAL.each { |name, type|
      if hsh.key?(name)
        val = hsh[name]
        Ballistics.check_type!(val, type)
        if name == "base"
          @base = self.class.base(val)
        else
          self.instance_variable_set("@#{name}", val)
        end
      end
    }
  end
end
