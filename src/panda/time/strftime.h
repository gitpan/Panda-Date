#pragma once
#include <panda/time/time.h>

namespace panda { namespace time {

size_t strftime (char* buf, size_t maxsize, const char* format, const dt* timeptr);
void printftime (const char* format, const dt* timeptr);
void printftime (const char* format, const struct tm* timeptr);

}}
