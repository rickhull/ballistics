# Background

This ruby extension is based on
[GNU Ballistics Library](https://sourceforge.net/projects/ballisticslib/), a
somewhat obscure and rarely updated C library which exists entirely on
SourceForge.

## GNU Ballistics Library

`gnu_ballistics.h` and `gnu_ballistics.c` are periodically copied from GBL
into this project and patched as necessary.  The most recent copy was from
[release `0.201 alpha`](https://sourceforge.net/projects/ballisticslib/files/GNU%20Ballistics%20Library/0.201%20alpha/)
last modified *2014-09-05*.  The prior version / copy has
an unknown provenance, possibly from release `0.100 alpha` *2008-02-08*.

`0.201 alpha` was patched so that `gnu_ballistics.c` includes
`gnu_ballistics.h`, rather than vice versa (is this a thing?).

## Ruby Extension

The extension is the bridge between the Ruby and C worlds.  It is written in
C and includes `ruby.h`, so that one can write C code with Ruby semantics and
full access to Ruby's object space.  Generally modules, classes, and/or
methods are defined.  These can be accessed from Ruby but execute as compiled
C code.

# Usage

```shell
cd ext/ballistics
```

Choose between Makefile and Rakefile below.  Rakefile is much preferred.
Makefile is included mostly for illustrative purposes.

## Makefile

### Create Makefile

```shell
ruby extconf.rb
```

### Compile Object Files

```shell
make
```

## Rakefile

### Prereqs

```shell
gem install rake-compiler rspec # sudo as nec
```

### Show Tasks

```shell
rake -T
```

### Build and Test

```shell
rake rebuild
```

# The Extension

The extension is defined in `ext.c`, which defines a function `Init_ext` (in
accordance with `extconf.rb` naming its target `ballistics/ext`).  `Init_ext`
creates the `Ballistics::Ext` module, which can be accessed from Ruby.  This
extension is written so that the C parts live inside `Ballistics::Ext`.
