#ifndef _LIB_H
#define _LIB_H

#ifdef __cpp_exceptions
#  define LIB_HAS_EXCEPTIONS
#endif

void throw_or_abort();

#ifdef LIB_HAS_EXCEPTIONS
void throw_or_fill();
void lib_except();
# else 
void throw_or_fill(const char **error);
void lib_noexcept();
#endif

#endif // _LIB_H