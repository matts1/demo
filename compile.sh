#!/bin/bash -eu

CC="clang++ -nostdinc -nostdinc++ -Ifirst -Isecond"

echo "Compiling without modules"
$CC main.cc -H -o /dev/null 

echo
echo "Compiling with modules"
$CC -c -x c++ -fmodules -fmodule-map-file=first/module.modulemap -Xclang -emit-module first/module.modulemap -fmodule-name=mbstate -H -o /dev/null