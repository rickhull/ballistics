require 'pp'
require 'ballistics/gun'

g = Ballistics::Gun.find
# => # a big hash ...

g.keys
# => ["ar15_carbine", "m4", "m16", "ar15_sbr", "ar15_300_blk", "1911", "mossberg_500"]

gun = g["m16"]
# => #<Ballistics::Gun ...

pp gun
<<EOF
#<Ballistics::Gun:0x0055a54a0bed58
 @barrel_length=20,
 @cartridges=[],
 @chamber="5.56",
 @extra={},
 @name="Standard M16 rifle with 20 inch barrel (5.56)",
 @sight_height=2.6,
 @yaml_data=
  {"name"=>"Standard M16 rifle with 20 inch barrel (5.56)",
   "sight_height"=>2.6,
   "barrel_length"=>20,
   "zero_range"=>100,
   "chamber"=>5.56},
 @zero_range=100>
EOF

c = gun.cartridges
# => # a big hash ...

c.keys
# ["test_cartridge"]

cart = c["test_cartridge"]
# => #<Ballistics::Cartridge ...

pp cart
<<EOF
#<Ballistics::Cartridge:0x00556b5b0ac050
 @case="5.56",
 @desc="5.56 test_cartridge with a test_projectile",
 @extra={},
 @muzzle_velocity={16=>3000, 5=>2000},
 @name="test 5.56 cartridge",
 @projectile=
  #<Ballistics::Projectile:0x00556b5b0a4918
   @ballistic_coefficient={"g1"=>1.5},
   @base="flat",
   @cal=50,
   @desc="A strange thing indeed",
   @drag_function=nil,
   @extra={},
   @g1=1.5,
   @grains=100,
   @intended="5.56",
   @name="The thing that goes out",
   @yaml_data=
    {"name"=>"The thing that goes out",
     "cal"=>50,
     "grains"=>100,
     "g1"=>1.5,
     "desc"=>"A strange thing indeed",
     "intended"=>5.56,
     "base"=>"flat"}>,
 @yaml_data=
  {"name"=>"test 5.56 cartridge",
   "case"=>5.56,
   "projectile"=>"test_projectile",
   "16_inch_fps"=>3000,
   "desc"=>"5.56 test_cartridge with a test_projectile",
   "5_inch_fps"=>2000}>
EOF

pp proj = cart.projectile
<<EOF
#<Ballistics::Projectile:0x00561bc7aff210
 @ballistic_coefficient={"g1"=>1.5},
 @base="flat",
 @cal=50,
 @desc="A strange thing indeed",
 @drag_function=nil,
 @extra={},
 @g1=1.5,
 @grains=100,
 @intended="5.56",
 @name="The thing that goes out",
 @yaml_data=
  {"name"=>"The thing that goes out",
   "cal"=>50,
   "grains"=>100,
   "g1"=>1.5,
   "desc"=>"A strange thing indeed",
   "intended"=>5.56,
   "base"=>"flat"}>
EOF

puts "Muzzle velocity for #{gun.barrel_length}" + '" ' +
     "barrel: #{cart.mv(gun.barrel_length)} FPS"
# Muzzle velocity for 20" barrel: 3350 FPS
