// The order here is irrelevant. It's undef'd regardless of which module comes first
#include "second.h"
#include "first.h"

#ifndef FIRST
#error SHOULD BE DEFINED
#endif