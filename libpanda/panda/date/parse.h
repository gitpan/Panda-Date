#ifndef pdate_parse_h_included
#define pdate_parse_h_included

#include "inc.h"

namespace panda { namespace date {

int  parse_iso           (const char*, size_t, panda::time::datetime*);
int  parse_relative      (const char*, size_t, panda::time::datetime*);
bool looks_like_relative (const char*);

};};

#endif
