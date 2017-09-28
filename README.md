# Ballistics-NG (next gen)

This gem is based on the **ballistics** gem, which has been abandoned since
2013.  It is anticipated that this gem will take over the **ballistics** name,
but until then, this gem is known as **ballistics-ng**

It consists of a C extension which wraps the GNU Ballistics C library
(which is not an official GNU project as far as I can tell) and some additional
Ruby code for managing input data.   Feed in projectile and atmospheric
specifics in order to retrieve trajectory information at range.

User-friendly features include the following:

* `Ballistics::Problem` -- specify a gun and cartridge (etc)
  for meaningful results
* `Ballistics::Atmosphere` -- `altitude`, `humidity`, `pressure`, `temp`;
  Army and ICAO atmospheres included at no charge
* `Ballistics::Gun` -- `rifles`, `pistols`, `shotguns` for namespaces;
  provides mainly a chamber (for cartridges) and a barrel length
  (for muzzle velocity)
* `Ballistics::Cartridge` -- organized by chamber (e.g. `300 BLK`);
  consists of a projectile along with case and powder charge (and primer)
* `Ballistics::Projectile` -- organized by chamber; has at least one
  *ballistic coefficient* and *drag function*

# Install

```
$ gem install ballistics-ng
```

# Usage

```ruby
require 'ballistics'

# do stuff
```
