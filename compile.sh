#!/bin/bash

mkdir -p out

PRECOMPILE="clang++ -fms-compatibility -Xclang -emit-module -fmodules -fmodule-map-file=module.modulemap -nostdinc -nostdinc++ -x c++-header module.modulemap"
set -x
$PRECOMPILE -o out/first.pcm -fmodule-name=first
$PRECOMPILE -o out/second.pcm -fmodule-name=second
$PRECOMPILE -o out/second.pcm -fmodule-name=second -fmodule-file=out/first.pcm
