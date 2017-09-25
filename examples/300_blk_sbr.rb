require 'ballistics/problem'

gun_type = 'rifles' # pistols|shotguns
gun_id = 'ar15_300_blk'
cart_id = 'barnes_110_vor_tx'

prob = Ballistics::Problem.new { |b|
  b.gun = Ballistics::Gun.find('rifles').fetch(gun_id)
  b.cartridge = b.gun.cartridges.fetch(cart_id)
  b.projectile = b.cartridge.projectile
}

puts [prob.multiline, Ballistics.table(prob.params)].join("\n\n")
