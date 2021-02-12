## Introduction

This is a port of the [kc87fpga core by beokim](https://github.com/beokim/kc87fpga) to the [MiSTer board](https://github.com/MiSTer-devel).

See http://en.wikipedia.org/wiki/Robotron_KC_87

Lots of info and documentation (in german) can be found here: https://www.sax.de/~zander/index2h.html

In a nutshell, it is an east german (DDR/GDR) computer based on soviet russian U880 CPU (Z80 clone). Compared to contemporary western imperialist machines it lacks real graphics, has only a character generator, but there is a Basic interpreter in its ROM.

## The MiSTer Core

The core is in a pretty basic state right now, there is no support for tape input or *.TAP files yet.

Type BASIC at the OS prompt to start the basic interpreter from ROM.

The character generator currently produces VGA type sync pulses, not TV PAL. Output on HDMI at slightly over 50Hz is OK, analog video is untested (i have no io board) and likely will not work.

## The Copyright Notice that came with the Sources

Copyright (c) 2015, $ME
All rights reserved.

Redistribution and use in source and synthezised forms, with or without modification, are permitted 
provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions 
   and the following disclaimer.

2. Redistributions in synthezised form must reproduce the above copyright notice, this list of conditions
   and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED 
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A 
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR 
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED 
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
POSSIBILITY OF SUCH DAMAGE.
