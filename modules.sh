#!/bin/bash -eu

PATH="$HOME/llvm-project/build-clang/bin:$PATH"
which clang++

D="out/modules"

run() {
    echo
    echo "$@"
    "$@"
}

expectfail() {
    set +e
    run "$@"
    if [[ "$?" -eq 0 ]]; then
        echo "Command unexpectedly succeeded"
    fi
    set -e
}

compile() {
  module_name="$1"
  out_name="$2"
  prefix="$D/${module_name}_${out_name}"
  shift
  shift
  # The `-emit-module` does not read lib.h. It reads the pcm file instead.
  run clang++ -cc1 -x c++ -emit-module -o "${prefix}.pcm" -fmodules modules.modulemap "-fmodule-name=$module_name" "$@"
  # This looks for the path of the .h file but does not read the contents. The path is used to determine the module map.
  run clang++ -cc1 -x c++ -emit-obj "${module_name}.cc" -fmodules -fmodule-map-file=modules.modulemap -fmodule-file="${prefix}.pcm" "-o" "${prefix}.o" "$@"
}

exc="-fexceptions -fcxx-exceptions"

compile lib noexcept
compile lib except $exc

compile user noexcept "-fmodule-file=$D/lib_noexcept.pcm"
compile user except $exc "-fmodule-file=$D/lib_except.pcm"

# Error: exception handling was disabled in PCH file but is currently enabled
expectfail compile user except_lib_noexcept $exc "-fmodule-file=$D/lib_noexcept.pcm"
compile user except_lib_noexcept $exc "-fmodule-file=$D/lib_noexcept.pcm" -Wno-module-file-config-mismatch
# Error: exception handling was enabled in PCH file but is currently disabled
expectfail compile user noexcept_lib_except "-fmodule-file=$D/lib_exceptions.pcm"
compile user noexcept_lib_except "-fmodule-file=$D/lib_except.pcm" -Wno-module-file-config-mismatch

run clang++ -o $D/main.o -c main.cc -fexceptions

run clang++ $D/lib_except.o $D/user_except.o $D/main.o -o $D/except
run clang++ $D/lib_noexcept.o $D/user_noexcept.o $D/main.o -o $D/noexcept

# In both these scenarios, we are able to link throw_or_abort because the function signature didn't change.
# Fails to link due to throw_or_fill
# Interestingly, if the mangled names are equivalent, even if they're different signatures, it'll still link.
# Presumably it'd be undefined behaviour at runtime though.
expectfail clang++ $D/lib_except.o $D/user_noexcept.o $D/main.o -o $D/bad1
# Fails to link due to throw_or_fill
expectfail clang++ $D/lib_noexcept.o $D/user_except.o $D/main.o -o $D/bad2

# In both these scenarios, we are able to link throw_or_abort because the function signature didn't change.
# Fails to link due to throw_or_fill
# Interestingly, if the mangled names are equivalent, even if they're different signatures, it'll still link.
# Presumably it'd be undefined behaviour at runtime though.
run clang++ $D/lib_except.o $D/user_noexcept_lib_except.o $D/main.o -o $D/user_noexcept_lib_except
# Fails to link due to throw_or_fill
run clang++ $D/lib_noexcept.o $D/user_except_lib_noexcept.o $D/main.o -o $D/user_noexcept_lib_except