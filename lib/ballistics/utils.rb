require 'bigdecimal'
require 'bigdecimal/util'

module Ballistics
  GRAINS = 7000.to_d # per lb
  G = 32.175.to_d    # gravitational acceleration, feet / s^2
  COMBO = GRAINS * G

  module Utils
    def self.sectional_density(weight, diameter)
      weight.to_d / (GRAINS * diameter.to_d ** 2)
    end

    def self.kinetic_energy(velocity, weight)
      weight.to_d * velocity.to_d ** 2 / (COMBO * 2)
    end

    def self.taylorko(velocity, weight, diameter)
      weight.to_d * velocity.to_d * diameter.to_d / GRAINS
    end

    def self.recoil_impulse(bullet_weight, propellant_weight,
                            velocity, propellant_velocity=4000)
      (bullet_weight.to_d * velocity.to_d +
       propellant_weight.to_d * propellant_velocity.to_d) /
        COMBO
    end

    def self.free_recoil(bullet_weight, propellant_weight,
                         velocity, firearm_weight, propellant_velocity=4000)
      G * recoil_impulse(bullet_weight, propellant_weight,
                         velocity, propellant_velocity) /
        firearm_weight.to_d
    end

    def self.recoil_energy(bullet_weight, propellant_weight,
                           velocity, firearm_weight, propellant_velocity=4000)
      fr = free_recoil(bullet_weight, propellant_weight,
                       velocity, firearm_weight, propellant_velocity)
      firearm_weight.to_d * fr ** 2 / (2 * G)
    end
  end
end
