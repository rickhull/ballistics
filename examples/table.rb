require 'ballistics/problem'

prob = Ballistics::Problem.simple(gun_family: 'rifles',
                                  gun_id: 'ar15_300_blk',
                                  cart_id: 'barnes_110_vor_tx')

puts prob.multiline
puts
puts
puts prob.table
