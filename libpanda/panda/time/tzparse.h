#pragma once
#include "time.h"

namespace panda { namespace time {

bool tzparse      (char*, tz*);
bool tzparse_rule (const char*, tzrule*);

};};
