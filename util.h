#ifndef xs_pdate_util_h_included
#define xs_pdate_util_h_included

#include "Date.h"

namespace panda { namespace xsdate {

Date* date_new   (SV* arg, tz* zone, Date* operand=NULL);
Date* date_set   (SV* arg, tz* zone, Date* operand=NULL);
Date* date_clone (SV* arg, tz* zone, Date* operand=NULL);

void        date_freeze (Date* date, char* buf);
const char* date_thaw   (ptime_t* epoch, tz** zone, const char* ptr, size_t len);

inline size_t date_freeze_len (Date* date) {
    if (date->timezone()->is_local) return sizeof(time_t);
    return sizeof(time_t) + strlen(date->timezone()->name);
}

DateRel* daterel_new (SV* arg, DateRel* operand=NULL);
DateRel* daterel_set (SV* arg, DateRel* operand=NULL);
DateRel* daterel_new (SV* from, SV* till, DateRel* operand=NULL);
DateRel* daterel_set (SV* from, SV* till, DateRel* operand=NULL);

DateInt* dateint_new (SV* arg, DateInt* operand=NULL);
DateInt* dateint_set (SV* arg, DateInt* operand=NULL);
DateInt* dateint_new (SV* from, SV* till, DateInt* operand=NULL);
DateInt* dateint_set (SV* from, SV* till, DateInt* operand=NULL);

HV* export_timezone (const tz* zone);

};};

#endif