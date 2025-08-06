#!/bin/bash -eu

D="$(dirname ${BASH_SOURCE[0]})"

mkdir -p "$D/out"

PRECOMPILE="${CC:-clang++} -fms-compatibility -Xclang -emit-module -fmodules -fmodule-map-file=$D/module.modulemap -nostdinc -nostdinc++ -x c++-header $D/module.modulemap -fno-implicit-modules"
set -x
$PRECOMPILE -o "$D/out/first.pcm" -fmodule-name=first
$PRECOMPILE -o "$D/out/second.pcm" -fmodule-name=second -fmodule-file="$D/out/first.pcm"
$PRECOMPILE -o "$D/out/third.pcm" -fmodule-name=third -fmodule-file="$D/out/first.pcm" -fmodule-file="$D/out/second.pcm"
