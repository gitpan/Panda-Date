#ifndef pdate_inc_h_included
#define pdate_inc_h_included

#include <algorithm>

#include "../util.h"
#include "../time.h"

namespace panda { namespace date {

using panda::time::dt;
using panda::time::ptime_t;

const int E_OK         = 0;
const int E_UNPARSABLE = 1;
const int E_RANGE      = 2;

inline static int epoch_cmp (ptime_t a, ptime_t b) {
    return a > b ? 1 : (a == b ? 0 : -1);
}

inline static ptime_t pseudo_epoch (const dt* date) {
    return date->sec + date->min*61 + date->hour*60*61 + date->mday*24*60*61 + date->mon*31*24*60*61 + date->year*12*31*24*60*61;
}

inline static int date_cmp (const dt* d1, const dt* d2) {
    return epoch_cmp(pseudo_epoch(d1), pseudo_epoch(d2));
}

};};

#endif
