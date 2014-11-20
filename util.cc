#include "util.h"

#define SV2C_NEW
#include "sv2class.h"
#undef SV2C_NEW

#define SV2C_SET
#include "sv2class.h"
#undef SV2C_SET

#define SV2C_CLONE
#include "sv2class.h"
#undef SV2C_CLONE

namespace xs { namespace date {

void date_freeze (Date* date, char* buf) {
    *((ptime_t*) buf) = PTIME_HTOBE64(date->epoch());
    buf += sizeof(ptime_t);
    
    if (date->timezone()->is_local) *buf = '\0';
    else strcpy(buf, date->timezone()->name);
}

const char* date_thaw (ptime_t* epoch, const tz** zone, const char* ptr, size_t len) {
    if (len < sizeof(ptime_t)) croak("Panda::Date: cannot 'thaw' - corrupted data");
    *epoch = PTIME_BE64TOH(*((ptime_t*) ptr));
    ptr += sizeof(ptime_t);
    if (*ptr == '\0') {
        *zone = NULL;
        return ptr;
    }
    size_t znlen = strlen(ptr);
    *zone = tzget(ptr);
    return ptr + znlen;
}

SV* export_transition (tztrans& trans, bool is_past) {
    HV* hv = newHV();
    hv_store(hv, "offset", 6, newSViv(trans.offset),    0);
    hv_store(hv, "abbrev", 6, newSVpv(trans.abbrev, 0), 0);
    if (!is_past) {
        hv_store(hv, "start",       5, newSViv(trans.start),      0);
        hv_store(hv, "isdst",       5, newSVuv(trans.isdst),      0);
        hv_store(hv, "gmt_offset", 10, newSViv(trans.gmt_offset), 0);
        hv_store(hv, "leap_corr",   9, newSViv(trans.leap_corr), 0);
        hv_store(hv, "leap_delta", 10, newSViv(trans.leap_delta), 0);
    }
    return newRV_noinc((SV*)hv);
}

HV* export_timezone (const tz* zone) {
    HV* ret = newHV();
    
    hv_store(ret, "name", 4, newSVpv(zone->name, 0), 0);
    hv_store(ret, "is_local", 8, newSViv(zone->is_local ? 1 : 0), 0);
    
    HV* future = newHV();
    hv_store(future, "hasdst", 6, newSVuv(zone->future.hasdst ? 1 : 0), 0);
    
    HV* outer = newHV();
    hv_store(outer, "abbrev", 6, newSVpv(zone->future.outer.abbrev, 0), 0);
    hv_store(outer, "offset", 6, newSViv(zone->future.outer.offset), 0);
    hv_store(outer, "gmt_offset", 10, newSViv(zone->future.outer.gmt_offset), 0);
    hv_store(outer, "isdst", 5, newSViv(zone->future.outer.isdst), 0);
    hv_store(future, "outer", 5, newRV_noinc((SV*) outer), 0);
    
    if (zone->future.hasdst) {
        HV* inner = newHV();
        hv_store(inner, "abbrev", 6, newSVpv(zone->future.inner.abbrev, 0), 0);
        hv_store(inner, "offset", 6, newSViv(zone->future.inner.offset), 0);
        hv_store(inner, "gmt_offset", 10, newSViv(zone->future.inner.gmt_offset), 0);
        hv_store(inner, "isdst", 5, newSViv(zone->future.inner.isdst), 0);
        
        HV* outer_end = newHV();
        hv_store(outer_end, "mon",  3, newSVuv(zone->future.outer.end.mon),  0);
        hv_store(outer_end, "week", 4, newSVuv(zone->future.outer.end.yday), 0);
        hv_store(outer_end, "day",  3, newSVuv(zone->future.outer.end.wday), 0);
        hv_store(outer_end, "hour", 4, newSViv(zone->future.outer.end.hour), 0);
        hv_store(outer_end, "min",  3, newSViv(zone->future.outer.end.min),  0);
        hv_store(outer_end, "sec",  3, newSViv(zone->future.outer.end.sec),  0);
        hv_store(outer, "end", 3, newRV_noinc((SV*) outer_end), 0);
        
        HV* inner_end = newHV();
        hv_store(inner_end, "mon",  3, newSVuv(zone->future.inner.end.mon),  0);
        hv_store(inner_end, "week", 4, newSVuv(zone->future.inner.end.yday), 0);
        hv_store(inner_end, "day",  3, newSVuv(zone->future.inner.end.wday), 0);
        hv_store(inner_end, "hour", 4, newSViv(zone->future.inner.end.hour), 0);
        hv_store(inner_end, "min",  3, newSViv(zone->future.inner.end.min),  0);
        hv_store(inner_end, "sec",  3, newSViv(zone->future.inner.end.sec),  0);
        hv_store(inner, "end", 3, newRV_noinc((SV*) inner_end), 0);
        
        hv_store(future, "inner", 5, newRV_noinc((SV*) inner), 0);
    }
    hv_store(ret, "future", 6, newRV_noinc((SV*) future), 0);
    
    AV* trans = newAV();
    for (int i = 0; i < zone->trans_cnt; i++) av_push(trans, export_transition(zone->trans[i], false));
    hv_store(ret, "transitions", 11, newRV_noinc((SV*) trans), 0);
    
    hv_store(ret, "past", 4, export_transition(zone->trans[0], true), 0);
    
    return ret;
}

}}
