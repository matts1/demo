#include "lib.h"

void throw_or_abort() {
#ifdef LIB_HAS_EXCEPTIONS
  throw "error";
#else
  // ABORT
#    endif
}

#ifdef LIB_HAS_EXCEPTIONS
void throw_or_fill() {
  throw "throw_or_fill error";
}
void lib_except() {}

# else 
void throw_or_fill(const char **err) {
  *err = "throw_or_fill_error";
}
void lib_noexcept() {}
#endif
