require 'ballistics'
require 'ballistics/projectile'
require 'ballistics/cartridge'
require 'ballistics/gun'
require 'ballistics/atmosphere'

class Ballistics::Problem
  def self.simple(gun_id:, cart_id:)
    self.new { |p|
      p.gun = Ballistics::Gun.fetch_id(gun_id)
      p.cartridge = p.gun.cartridges.fetch(cart_id)
      p.projectile = p.cartridge.projectile
    }
  end

  attr_accessor :projectile, :cartridge, :gun, :atmosphere

  def initialize
    @projectile = nil
    @cartridge = nil
    @gun = nil
    @atmosphere = nil

    yield self if block_given?
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
