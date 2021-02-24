## Introduction

This is a port of the [kc87fpga core by beokim](https://github.com/beokim/kc87fpga) to the [MiSTer board](https://github.com/MiSTer-devel).

See http://en.wikipedia.org/wiki/Robotron_KC_87

Lots of info and documentation (in german) can be found here: https://www.sax.de/~zander/index2h.html

In a nutshell, it is an east german (DDR/GDR) computer based on soviet russian U880 CPU (Z80 clone). Compared to contemporary western imperialist machines it lacks real graphics, has only a character generator, but there is a Basic interpreter in its ROM.

![KC87](pics/KC87.png?raw=true "KC87")
![Mondlandung](pics/Mondlandung.png?raw=true "Mondlandung")

## The MiSTer Core

The core is in a pretty basic state right now, there is no support for tape input yet, but *.TAP files work. A lot of things seem to be working a little/way too fast, i will have a look at slowing down memory access soon. And don't expect any audio output for now.

Type BASIC at the OS prompt to start the basic interpreter from ROM.

The character generator currently produces VGA type sync pulses, not TV PAL. Output on HDMI at slightly over 50Hz is OK, analog video is untested (i have no io board) and likely will not work.

## CPU Turbo

CPU Turbo is selectable in OSD menu, default is off as games are nearly unplayable at that speed.

## TAP files

A little warning: i have not yet found any games/software suitable for non-german speakers. OS errors are reported in english though.

The *.TAP files need to be in your games/kc87 folder.

Some BASIC games/tools can be found at the [KC-Club Homepage](https://www.iee.et.tu-dresden.de/~kc-club/09/RUBRIK38.HTM) in (not supported) *.SSS file format.

SSS files need to be converted to *.TAP files to be usable. [The JKCEMU KC emulator](http://www.jens-mueller.org/jkcemu/index.html) can be used to do that. See [the link 'Dateikonverter'](http://www.jens-mueller.org/jkcemu/fileconverter.html) for some info in german. In short, start the emulator, select Extra->Werkzeuge->Dateikonverter, open the file (Datei), select 'KC-TAP-BASIC-Datei' and click 'Konvertieren' to save the TAP file.

There are a few converted games in the tap folder in the repository.

How to load and start a game:
1. type BASIC at the OS prompt and press enter when asked for MEMORY-END
1. type CLOAD"*name*" and press enter, substitute *name* for the TAP file you want to load
1. go to the osd and load the TAP file
1. now the name of the game and a slowly moving cursor should appear
1. grab some coffee and/or watch the disk led blinking
1. type run to start the game when the prompt reappears

To get a feeling for the transfer speed involved, see [this video](https://youtu.be/Oi6K0Y1p6PQ)

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
