require 'ballistics'
require 'ballistics/gun'

gun_family = 'rifles'
gun_id = 'ar15_300_blk'
cart_id = "barnes_110_vor_tx"

gun = Ballistics::Gun.load(gun_family).fetch(gun_id)
cart = gun.cartridges.fetch(cart_id)
mv = cart.mv(gun.barrel_length)
proj = cart.projectile

params = {
  drag_function: proj.drag_function,
  ballistic_coefficient: proj.bc,
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
cart.muzzle_velocity.keys.sort.each { |bl|
  puts "MV @ #{bl}:".rjust(10, ' ') + " #{cart.muzzle_velocity[bl]}"
}
puts " Muzzle V:"
puts "     Desc: #{cart.desc}" if cart.desc
puts
puts "Projectile: #{proj.name}"
puts "=========="
puts "   Caliber: #{proj.cal}"
puts "    Grains: #{proj.grains}"
proj.ballistic_coefficient.keys.sort.each { |model|
  puts "BC (#{model.upcase}):".rjust(11, ' ') +
       " #{proj.ballistic_coefficient[model]}"
}
puts "      Desc: #{proj.desc}" if proj.desc
puts
puts
puts Ballistics.table(params)
