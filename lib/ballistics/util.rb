require 'bigdecimal'
require 'bigdecimal/util'

module Ballistics
  # weight in grains
  # velocity in ft / s
  # acceleration in ft / s^2
  # caliber in inches

  GRAINS_PER_LB = 7000.to_d
  G = 32.175.to_d            # gravitational acceleration

  def self.lbs(grains)
    grains.to_d / GRAINS_PER_LB
  end

  def self.grains(lbs)
    lbs.to_d * GRAINS_PER_LB
  end

  def self.mass(weight)
    weight.to_d / G
  end

  # Sectional density, according to the SpeerReloading Manual No. 13,
  # is defined as: "A bullet's weight in pounds divided by the square of
  # its diameter in inches." Note that SD is independent of a bullet's
  # shape. All bullets of the same caliber and weight will have the same
  # SD, regardless of their shape or composition.
  #
  def self.sectional_density(weight, caliber)
    self.lbs(weight) / caliber.to_d ** 2
  end

  # 1/2 m v^2
  #
  def self.kinetic_energy(velocity, weight)
    self.mass(self.lbs(weight)) * velocity.to_d ** 2 / 2
  end

  # http://www.chuckhawks.com/taylor_KO_factor.htm
  # tl;dr don't use this
  #
  def self.taylor_ko(velocity, weight, caliber)
    self.lbs(weight) * velocity.to_d * caliber.to_d
  end

  def self.recoil_impulse(bullet_weight, propellant_weight,
                          velocity, propellant_velocity=4000)
    self.mass(self.lbs(bullet_weight.to_d * velocity.to_d +
                       propellant_weight.to_d * propellant_velocity.to_d))
  end

  def self.free_recoil(bullet_weight, propellant_weight,
                       velocity, firearm_lbs, propellant_velocity=4000)
    self.recoil_impulse(bullet_weight, propellant_weight,
                        velocity, propellant_velocity) / self.mass(firearm_lbs)
  end

  # 1/2 m(firearm) * fr^2
  #
  def self.recoil_energy(bullet_weight, propellant_weight,
                         velocity, firearm_lbs, propellant_velocity=4000)
    fr = self.free_recoil(bullet_weight, propellant_weight,
                          velocity, firearm_lbs, propellant_velocity)
    self.mass(firearm_lbs) * fr ** 2 / 2
  end
end
