#!/bin/bash -eu

D="out/no-modules"

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

rm -rf $D
mkdir -p $D
run clang++ -o $D/main.o -c main.cc -fexceptions
run clang++ -o $D/lib_exceptions.o -c lib.cc -fexceptions
run clang++ -o $D/lib_no_exceptions.o -c lib.cc -fno-exceptions
run clang++ -o $D/user_exceptions.o -c user.cc -fexceptions
run clang++ -o $D/user_no_exceptions.o -c user.cc -fno-exceptions

run clang++ $D/lib_exceptions.o $D/user_exceptions.o $D/main.o -o $D/with_exceptions
run clang++ $D/lib_no_exceptions.o $D/user_no_exceptions.o $D/main.o -o $D/no_exceptions

# In both these scenarios, we are able to link throw_or_abort because the function signature didn't change.
# Fails to link due to throw_or_fill
# Interestingly, if the mangled names are equivalent, even if they're different signatures, it'll still link.
# Presumably it'd be undefined behaviour at runtime though.
expectfail clang++ $D/lib_exceptions.o $D/user_no_exceptions.o $D/main.o -o $D/remove_exceptions
# Fails to link due to throw_or_fill
expectfail clang++ $D/lib_no_exceptions.o $D/user_exceptions.o $D/main.o -o $D/add_exceptions

