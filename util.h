#pragma once
#include "Date.h"

namespace xs { namespace date {

Date* date_new   (SV* arg, const tz* zone, Date* operand=NULL);
Date* date_set   (SV* arg, const tz* zone, Date* operand=NULL);
Date* date_clone (SV* arg, const tz* zone, Date* operand=NULL);

void        date_freeze (Date* date, char* buf);
const char* date_thaw   (ptime_t* epoch, const tz** zone, const char* ptr, size_t len);

inline size_t date_freeze_len (Date* date) {
    if (date->timezone()->is_local) return sizeof(ptime_t);
    return sizeof(ptime_t) + strlen(date->timezone()->name);
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

}}
