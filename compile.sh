#!/bin/bash

mkdir -p out

CC="clang++ -fno-implicit-modules -fmodules -nostdinc -nostdinc++"
PRECOMPILE="$CC -Xclang -emit-module -x c++-header foo.modulemap"
set -x
$PRECOMPILE -o out/first.pcm -fmodule-map-file=foo.modulemap -fmodule-name=first
$PRECOMPILE -o out/second.pcm -fmodule-map-file=foo.modulemap  -fmodule-name=second
$PRECOMPILE -o out/second.pcm -fmodule-map-file=foo.modulemap -fmodule-name=third -fmodule-file=out/first.pcm -fmodule-file=out/second.pcm
$CC -fmodule-file=out/first.pcm non_module.cc -o out/non_module -MMD -MF out/non_module.d
$CC -fmodule-map-file=foo.modulemap -fmodule-file=out/first.pcm non_module.cc -o out/non_module_failed -MMD -MF out/non_module_failed.d