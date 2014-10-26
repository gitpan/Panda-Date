#ifndef pdate_parse_h_included
#define pdate_parse_h_included

#include "inc.h"

namespace panda { namespace date {

err_t parse_iso           (const char*, size_t, panda::time::datetime*);
err_t parse_relative      (const char*, size_t, panda::time::datetime*);
bool  looks_like_relative (const char*);

};};

#endif
