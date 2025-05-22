#include "lib.h"
#include "user.h"

#ifdef LIB_HAS_EXCEPTIONS
#ifdef __cpp_exceptions
#warning "pure except"
#else
#warning "user_noexcept_lib_except"
#endif
#else
#ifdef __cpp_exceptions
#warning "user_except_lib_noexcept"
#else
#warning "pure noexcept"
#endif
#endif


int fn() {
#ifdef LIB_HAS_EXCEPTIONS
  lib_except();
  throw_or_fill();
#else
  const char* err = nullptr;
  lib_noexcept();
  throw_or_fill(&err);
  if (err) {
    // handle error
  }
#endif

  throw_or_abort();
  return 0;
}
