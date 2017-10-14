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
 @cartridges={},
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
# ["test_cartridge", "m193", "federal_xm193"]

cart = c["m193"]
# => #<Ballistics::Cartridge ...

pp cart
<<EOF
#<Ballistics::Cartridge:0x005568e9340e70
 @case="5.56",
 @desc=
  "* Standard 55gr M193 ball ammo (FMJ)\n" +
  "* 9-12\" twist; 7\" OK\n" +
  "* 52-55k PSI chamber pressure\n",
 @extra={},
 @muzzle_velocity={20=>3250, 16=>3050},
 @name="M193 FMJ 55gr 5.56",
 @powder_type="imr4475",
 @projectile=
  #<Ballistics::Projectile:0x005568e933c780
   @ballistic_coefficient={"g1"=>0.269, "g7"=>0.12},
   @base="boat",
   @cal=5.56,
   @desc="M193 55gr FMJ",
   @drag_function=nil,
   @extra={},
   @g1=0.269,
   @g7=0.12,
   @grains=55,
   @intended="5.56",
   @name="M193 55gr FMJ",
   @yaml_data=
    {"name"=>"M193 55gr FMJ",
     "cal"=>5.56,
     "grains"=>55,
     "g1"=>0.269,
     "g7"=>0.12,
     "desc"=>"M193 55gr FMJ",
     "intended"=>5.56,
     "base"=>"boat"}>,
 @yaml_data=
  {"name"=>"M193 FMJ 55gr 5.56",
   "case"=>5.56,
   "projectile"=>"m193",
   "20_inch_fps"=>3250,
   "16_inch_fps"=>3050,
   "desc"=>
    "* Standard 55gr M193 ball ammo (FMJ)\n" +
    "* 9-12\" twist; 7\" OK\n" +
    "* 52-55k PSI chamber pressure\n",
   "powder_type"=>"imr4475"}>
EOF

pp proj = cart.projectile
<<EOF
#<Ballistics::Projectile:0x005568e933c780
 @ballistic_coefficient={"g1"=>0.269, "g7"=>0.12},
 @base="boat",
 @cal=5.56,
 @desc="M193 55gr FMJ",
 @drag_function=nil,
 @extra={},
 @g1=0.269,
 @g7=0.12,
 @grains=55,
 @intended="5.56",
 @name="M193 55gr FMJ",
 @yaml_data=
  {"name"=>"M193 55gr FMJ",
   "cal"=>5.56,
   "grains"=>55,
   "g1"=>0.269,
   "g7"=>0.12,
   "desc"=>"M193 55gr FMJ",
   "intended"=>5.56,
   "base"=>"boat"}>
EOF

puts "Muzzle velocity for #{gun.barrel_length}" + '" ' +
     "barrel: #{cart.mv(gun.barrel_length)} FPS"
# Muzzle velocity for 20" barrel: 3250 FPS
