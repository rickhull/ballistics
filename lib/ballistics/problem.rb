require 'ballistics'
require 'ballistics/projectile'
require 'ballistics/cartridge'
require 'ballistics/gun'
require 'ballistics/atmosphere'

class Ballistics::Problem
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

  def params
    hsh = {}
    hsh.merge!(@projectile.params) if @projectile
    hsh.merge!(@gun.params) if @gun
    hsh[:atmosphere] = @atmosphere if @atmosphere
    hsh[:velocity] = @cartridge.mv(@gun.barrel_length) if @cartridge and @gun
    hsh
  end

  def multiline
    lines = []
    lines << @gun.multiline if @gun
    lines << @cartridge.multiline if @cartridge
    lines << @projectile.multiline if @projectile
    lines << @atmosphere.multiline if @atmosphere
    lines.join("\n\n")
  end
end
