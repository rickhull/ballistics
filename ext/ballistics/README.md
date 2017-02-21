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

## Makefile

```shell
ruby extconf.rb

# creates Makefile

make

# creates gnu_ballistics.o ext.o ext.so
```

## Rakefile

```shell
gem install rake-compiler rspec # sudo as nec

rake -T

rake rebuild
```
