# Ballistics-NG (next gen)

This gem is based on the **ballistics** gem, which has been abandoned since
2013.  It is anticipated that this gem will take over the **ballistics** name,
but until then, this gem is known as **ballistics-ng**

It consists of a C extension which wraps the GNU Ballistics C library
(which is not an official GNU project as far as I can tell) and some additional
Ruby code for managing input data.   Feed in projectile and atmospheric
specifics in order to retrieve trajectory information at range.

# Install

```
$ gem install ballistics-ng
```

# Usage

```ruby
require 'ballistics'

# do stuff
```
