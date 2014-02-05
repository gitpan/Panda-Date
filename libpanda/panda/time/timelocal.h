#pragma once

namespace panda { namespace time {

ptime_t timelocall (dt*);
ptime_t timelocal  (dt*);
ptime_t timeanyl   (dt*, const tz*);
ptime_t timeany    (dt*, const tz*);

inline int _tl_binfind (ptime_t, const tz*);

#ifdef __GNUC__
inline ptime_t itimeanyl   (dt* date, const tz* zone) __attribute__((always_inline));
inline ptime_t itimeany    (dt* date, const tz* zone) __attribute__((always_inline));
inline ptime_t itimelocall (dt* date)                 __attribute__((always_inline));
inline ptime_t itimelocal  (dt* date)                 __attribute__((always_inline));
#endif 

inline ptime_t itimeanyl (dt* date, const tz* zone) {
    if (date->isdst > 0) {
#undef PTIME_AMBIGUOUS_LATER
#include "timeany.h"
    } else {
#define PTIME_AMBIGUOUS_LATER
#include "timeany.h"
    }
}

inline ptime_t itimeany (dt* date, const tz* zone) {
#define PTIME_ANY_NORMALIZE
    if (date->isdst > 0) {
#undef PTIME_AMBIGUOUS_LATER
#include "timeany.h"
    } else {
#define PTIME_AMBIGUOUS_LATER
#include "timeany.h"
    }
#undef PTIME_ANY_NORMALIZE
}

inline ptime_t itimelocall (dt* date) {
    return itimeanyl(date, tzlocal());
}

inline ptime_t itimelocal (dt* date) {
    return itimeany(date, tzlocal());
}

};};
