require 'bigdecimal'
require 'bigdecimal/util'

module Ballistics
  # weight in grains
  # velocity in ft / s
  # acceleration in ft / s^2
  # caliber in inches

  GRAINS_PER_LB = 7000.to_d
  G = 32.175.to_d    # gravitational acceleration, feet / s^2

  # Sectional density, according to the SpeerReloading Manual No. 13,
  # is defined as: "A bullet's weight in pounds divided by the square of
  # its diameter in inches." Note that SD is independent of a bullet's
  # shape. All bullets of the same caliber and weight will have the same
  # SD, regardless of their shape or composition.
  def self.sectional_density(weight, caliber)
    (weight.to_d / GRAINS_PER_LB) / caliber.to_d ** 2
  end

  def self.kinetic_energy(velocity, weight)
    (weight.to_d / GRAINS_PER_LB) * velocity.to_d ** 2 / (G * 2)
  end

  def self.taylor_ko(velocity, weight, caliber)
    (weight.to_d / GRAINS_PER_LB) * velocity.to_d * caliber.to_d
  end

  def self.recoil_impulse(bullet_weight, propellant_weight,
                          velocity, propellant_velocity=4000)
    (bullet_weight.to_d * velocity.to_d +
     propellant_weight.to_d * propellant_velocity.to_d) /
      (GRAINS_PER_LB * G)
  end

  def self.free_recoil(bullet_weight, propellant_weight,
                       velocity, firearm_lbs, propellant_velocity=4000)
    G * recoil_impulse(bullet_weight, propellant_weight,
                       velocity, propellant_velocity) /
      firearm_lbs.to_d
  end

  def self.recoil_energy(bullet_weight, propellant_weight,
                         velocity, firearm_lbs, propellant_velocity=4000)
    fr = free_recoil(bullet_weight, propellant_weight,
                     velocity, firearm_lbs, propellant_velocity)
    firearm_lbs.to_d * fr ** 2 / (G * 2)
  end
end
