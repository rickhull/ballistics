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

`0.201 alpha` was patched so that `gnu_ballistics.c` `#include`s
`gnu_ballistics.h`, rather than vice versa (is this a thing?).

# ext.c

TBD
