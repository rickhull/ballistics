require 'ballistics/problem'

gun_type = 'rifles' # pistols|shotguns
gun_id = 'ar15_300_blk'
cart_id = 'barnes_110_vor_tx'

prob = Ballistics::Problem.simple(gun_id: gun_id, cart_id: cart_id)

puts [prob.multiline, Ballistics.table(prob.params)].join("\n\n")
