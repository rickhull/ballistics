require 'ballistics/problem'

prob = Ballistics::Problem.simple(gun_family: 'rifles',
                                  gun_id: 'ar15_300_blk',
                                  cart_id: 'barnes_110_vor_tx')

puts [prob.multiline, Ballistics.table(prob.params)].join("\n\n")
