[![Build Status](https://travis-ci.org/rickhull/ballistics.svg)](https://travis-ci.org/rickhull/ballistics)
[![Gem Version](https://badge.fury.io/rb/ballistics-ng.svg)](http://badge.fury.io/rb/ballistics-ng)
[![Dependency Status](https://gemnasium.com/rickhull/ballistics.svg)](https://gemnasium.com/rickhull/ballistics)

# Ballistics-NG (next gen)

This gem consists of a C extension which wraps the "GNU Ballistics" C library
(which is not an official GNU project as far as I can tell) and some
additional Ruby code for managing input data.

Feed in projectile and atmospheric specifics in order to retrieve trajectory
information at range.

This project is originally based on the **ballistics** gem, which has been
abandoned since 2013.  It is anticipated that this gem will take over the
**ballistics** name, but until then, this gem is known as **ballistics-ng**

# Install

```
$ gem install ballistics-ng
```

# Usage

```ruby
require 'ballistics/problem'

prob = Ballistics::Problem.simple(gun_family: 'rifles',
                                  gun_id: 'ar15_300_blk',
			          cart_id: 'barnes_110_vor_tx')

puts prob.report
puts
puts
puts prob.table
```

```
$ ruby -Ilib examples/table.rb

GUN: AR-15 with 10.5 inch barrel (300 BLK)
===
      Chamber: 300 BLK
Barrel length: 10.5
 Sight height: 2.6
   Zero Range: 50

CARTRIDGE: Barnes 300 BLK 110gr VOR-TX
=========
   Case: 300 BLK
MV @ 10: 2180
MV @ 16: 2350
   Desc: Hunting round for penetration and expansion

PROJECTILE: Barnes 110gr TAC-TX 300 BLK
==========
Caliber: 0.308
 Grains: 110
BC (G1): 0.289
   Desc: Black polymer tip, copper bullet


Range   Time    FPS     Path
0       0.000   2180.0  -2.6
50      0.072   2043.1  -0.0
100     0.147   1911.8  0.5
150     0.229   1786.0  -1.4
200     0.316   1666.5  -6.0
250     0.409   1553.7  -13.7
300     0.509   1448.3  -25.1
350     0.616   1351.2  -40.6
400     0.731   1263.9  -60.9
450     0.854   1187.7  -86.6
500     0.983   1123.6  -118.5
```

# Features

## `Ballistics::Problem`

* specify a gun and cartridge (etc) for meaningful results

## `Ballistics::Atmosphere`

* specify altitude, humidity, pressure, and temp
* Army and ICAO atmospheres included at no charge

## `Ballistics::Gun`

* determines sight height, zero angle, chamber,
  muzzle velocity per barrel length
* determines the cartridge by chamber

## `Ballistics::Cartridge`

* organized by chamber (e.g. *300 BLK*)
* *projectile* (see below)
* *case* (determines the chamber)
* optionally: *powder charge* (and *primer*) details

## `Ballistics::Projectile`

* organized by chamber
* determines caliber, grains, ballistic coefficient, and drag function

## Built In YAML Components

* [guns](https://github.com/rickhull/ballistics/tree/master/lib/ballistics/guns)
* [cartridges](https://github.com/rickhull/ballistics/tree/master/lib/ballistics/cartridges)
* [projectiles](https://github.com/rickhull/ballistics/tree/master/lib/ballistics/projectiles)
