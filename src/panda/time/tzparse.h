#pragma once
#include <panda/time/time.h>

namespace panda { namespace time {

bool tzparse      (char*, tz*);
bool tzparse_rule (const char*, tzrule*);

}}
