module Ballistics
  require 'bigdecimal'
  require 'bigdecimal/util'

  UNIT_CORRECTION_FACTOR = 225400.to_d # (7000 gr./lb. * 32.2 f.p.s. ** 2)
  ACCELERATION_OF_GRAVITY = 32.2.to_d

  module Utils
    def self.sectional_density(bullet_weight, bullet_diameter)
      return ((bullet_weight.to_d / 7000.to_d) / (bullet_diameter.to_d ** 2.to_d))
    end

    def self.kinetic_energy(velocity, bullet_weight)
      return (0.5.to_d * bullet_weight.to_d * velocity.to_d ** 2.to_d / 7000.to_d / 32.175.to_d)
    end

    def self.taylorko(velocity, bullet_weight, bullet_diameter)
      return ((bullet_weight.to_d * velocity.to_d * bullet_diameter.to_d) / 7000.to_d)
    end

    def self.recoil_impulse(bullet_weight, propellant_weight, velocity, propellant_velocity=4000)
      return (bullet_weight.to_d * velocity.to_d + propellant_weight.to_d * propellant_velocity.to_d) / UNIT_CORRECTION_FACTOR
    end

    def self.free_recoil(bullet_weight, propellant_weight, velocity, firearm_weight, propellant_velocity=4000)
      recoil_impulse = recoil_impulse(bullet_weight, propellant_weight, velocity, propellant_velocity)
      return (ACCELERATION_OF_GRAVITY * recoil_impulse.to_d / firearm_weight.to_d)
    end

    def self.recoil_energy(bullet_weight, propellant_weight, velocity, firearm_weight, propellant_velocity=4000)
      free_recoil = free_recoil(bullet_weight, propellant_weight, velocity, firearm_weight, propellant_velocity)
      return (firearm_weight.to_d * free_recoil.to_d ** 2.to_d / (ACCELERATION_OF_GRAVITY * 2.to_d))
    end
  end

end
