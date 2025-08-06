#ifdef FIRST
#error A
#endif

#include "first.h"

#ifndef FIRST
#error B
#endif

#undef FIRST

#ifdef FIRST
#error C
#endif