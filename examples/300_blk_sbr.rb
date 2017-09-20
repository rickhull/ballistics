require 'ballistics'
require 'ballistics/gun'

gun_family = 'rifles'
gun_id = 'ar15_300_blk'
cart_id = "barnes_110_vor_tx"

gun = Ballistics::Gun.load(gun_family).fetch(gun_id)
cart = gun.cartridges.fetch(cart_id)
mv = cart.mv(gun.barrel_length)

params = {
  drag_function: cart.projectile.drag_function,
  ballistic_coefficient: cart.projectile.bc,
  velocity: cart.mv(gun.barrel_length),
  sight_height: gun.sight_height,
  zero_range: gun.zero_range,
}

puts
puts "Gun: #{gun.name}"
puts "==="
puts "      Chamber: #{gun.chamber}"
puts "Barrel length: #{gun.barrel_length}"
puts " Sight height: #{gun.sight_height}"
puts "   Zero Range: #{gun.zero_range}"
puts
puts "Cartridge: #{cart.name}"
puts "========="
puts "     Case: #{cart.case}"
puts "     Desc: #{cart.desc}" if cart.desc
puts
puts "Projectile: #{cart.projectile.name}"
puts "=========="
puts "   Caliber: #{cart.projectile.cal}"
puts "    Grains: #{cart.projectile.grains}"
puts "      Desc: #{cart.projectile.desc}" if cart.projectile.desc
puts "        " +
     [cart.projectile.drag_function, cart.projectile.bc].join(': ')
puts
puts
puts Ballistics.table(params)
