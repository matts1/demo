#!/bin/bash

mkdir -p out

CC="clang++ -fno-implicit-modules -fmodules -nostdinc -nostdinc++"
set -x
$CC  -Xclang -emit-module -x c++-header -o out/foobar.pcm -fmodule-map-file=module.modulemap -fmodule-name=foobar module.modulemap 
$CC -fmodule-file=out/foobar.pcm main.cc -o out/main