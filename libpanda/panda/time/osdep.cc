#include "time.h"

namespace panda { namespace time {

bool _from_env (char* lzname, const char* envar) {
    const char* val = getenv(envar);
    if (val == NULL) return false;
    size_t len = strlen(val);
    if (len < 1 || len > TZNAME_MAX) return false;
    strcpy(lzname, val);
    return true;
}

bool _tz_lzname (char* lzname);

#ifdef PTIME_OSTYPE_UNIX
#  include "unix.h"
#elif defined PTIME_OSTYPE_VMS
#  include "vms.h"
#elif defined PTIME_OSTYPE_WIN
#  include "win.h"
#else
#  error "Should not be here"
#endif

void tz_lzname (char* lzname) {
    if (_from_env(lzname, "TZ") || _tz_lzname(lzname)) return;
	strcpy(lzname, PTIME_GMT_FALLBACK);
}

};};
