require 'ballistics'
require 'ballistics/projectile'
require 'ballistics/cartridge'
require 'ballistics/gun'
require 'ballistics/atmosphere'

class Ballistics::Problem
  DEFAULTS = {
    shooting_angle: 0, # degrees; downhill 0 to -90, uphill 0 to +90
    wind_speed:     0, # mph
    wind_angle:    90, # degrees; 0-360 clockwise; 90 right, 270 left
    interval:      50, # yards
    max_range:    500, # yards
    y_intercept:    0, # inches; -2 means POI 2 inches below POA @ zero range
  }

  def self.simple(gun_id:, cart_id:, gun_family: nil)
    if gun_family
      gun = Ballistics::Gun.find(gun_family).fetch(gun_id)
    else
      gun = Ballistics::Gun.fetch_id(gun_id)
    end
    cart = gun.cartridges.fetch(cart_id)
    self.new(projectile: cart.projectile,
             cartridge: cart,
             gun: gun)
  end

  def self.zero_angle(opts = {})
    opts[:y_intercept] ||= 0
    args = [
      :drag_number,
      :ballistic_coefficient,
      :velocity,
      :sight_height,
      :zero_range,
      :y_intercept,
    ].map { |arg| opts.fetch(arg) }

    Ballistics::Ext.zero_angle(*args)
  end

  def self.trajectory(opts = {})
    opts[:zero_angle] ||= self.zero_angle(opts)
    args = [
      :drag_number,
      :ballistic_coefficient,
      :velocity,
      :sight_height,
      :shooting_angle,
      :zero_angle,
      :wind_speed,
      :wind_angle,
      :max_range,
      :interval,
    ].map { |arg| opts.fetch(arg) }

    Ballistics::Ext.trajectory(*args)
  end

  def self.table(opts = {})
    trj = opts[:trajectory] || self.trajectory(opts)
    items = {
      "Range" => "range",
      "Time" => "time",
      "FPS" => "velocity",
      "MOA" => "moa_correction",
    }
    items.keys.join("\t") + "\n" +
      trj.map { |h| "%i\t%0.3f\t%0.1f\t%0.1f" % items.values.map { |i| h[i] }
    }.join("\n")
  end

  attr_accessor :projectile, :cartridge, :gun, :atmosphere

  def initialize(projectile: nil,
                 cartridge: nil,
                 gun: nil,
                 atmosphere: nil)
    @projectile = projectile
    @cartridge = cartridge
    @gun = gun
    @atmosphere = atmosphere
  end

  def params(opts = {})
    mine = {}
    mine.merge!(@projectile.params) if @projectile
    mine.merge!(@gun.params) if @gun
    mine[:velocity] = @cartridge.mv(@gun.barrel_length) if @cartridge and @gun
    ret = DEFAULTS.merge(mine.merge(opts))

    # validate drag function and replace with the numeral
    ret[:drag_number] ||=
      Ballistic::Projectile.drag_number(ret[:drag_function])
    # apply atmospheric correction to ballistic coefficient
    ret[:ballistic_coefficient] = self.adjust(ret[:ballistic_coefficient])

    ret
  end

  def multiline
    lines = []
    lines << @gun.multiline if @gun
    lines << @cartridge.multiline if @cartridge
    lines << @projectile.multiline if @projectile
    lines << @atmosphere.multiline if @atmosphere
    lines.join("\n\n")
  end

  # apply atmospheric correction to a ballistic coefficient
  def adjust(bc)
    @atmosphere ? @atmosphere.translate(bc) : bc
  end

  def zero_angle(opts = {})
    self.class.zero_angle self.params opts
  end

  def trajectory(opts = {})
    self.class.trajectory self.params opts
  end

  def table(opts = {})
    self.class.table self.params opts
  end
end
