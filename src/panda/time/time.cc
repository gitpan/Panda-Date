#include <panda/time/time.h>

namespace panda { namespace time {

#define __PTIME_TRANS_BINFIND(VAR, FIELD) \
    int index = -1; \
    int low = 0; \
    int high = zone->trans_cnt; \
    while (high - low > 1) { \
        int mid = (high+low)/2; \
        if (zone->trans[mid].FIELD > VAR) high = mid; \
        else if (zone->trans[mid].FIELD < VAR) low = mid; \
        else { index = mid; break; } \
    } \
    if (index < 0) index = high - 1;

#define _PTIME_LT_LEAPSEC_CORR(source) \
    if (epoch < source.leap_end) result->sec = 60 + epoch - source.start;

inline ptime_t _calc_rule_epoch (int is_leap, const dt* curdate, dt border) {
    border.mday = (border.wday + curdate->yday - MON2YDAY[is_leap][border.mon] - curdate->wday + 378) % 7 + 7*border.yday - 6;
    if (border.mday > DAYS_IN_MONTH[is_leap][border.mon]) border.mday -= 7;
    border.year = curdate->year;
    return itimegmll(&border);
}

void gmtime (ptime_t epoch, dt* result) {
    igmtime(epoch, result);
}

ptime_t timegm (dt *date) {
    return itimegm(date);
}

ptime_t timegml (dt *date) {
    return itimegml(date);
}

void anytime (ptime_t epoch, dt* result, const tz* zone) {
    if (epoch < zone->ltrans.start) {
        __PTIME_TRANS_BINFIND(epoch, start);
        igmtime(epoch + zone->trans[index].offset, result);
        result->gmtoff = zone->trans[index].gmt_offset;
        result->n_zone = zone->trans[index].n_abbrev;
        result->isdst  = zone->trans[index].isdst;
        _PTIME_LT_LEAPSEC_CORR(zone->trans[index]);
    }
    else if (!zone->future.hasdst) { // future with no DST
        igmtime(epoch + zone->future.outer.offset, result);
        result->n_zone = zone->future.outer.n_abbrev;
        result->gmtoff = zone->future.outer.gmt_offset;
        result->isdst  = zone->future.outer.isdst; // some zones stay in dst in future (when no POSIX string and last trans is in dst)
        _PTIME_LT_LEAPSEC_CORR(zone->ltrans);
    }
    else {
        igmtime(epoch + zone->future.outer.offset, result);
        int is_leap = is_leap_year(result->year);

        if ((epoch >= _calc_rule_epoch(is_leap, result, zone->future.outer.end) - zone->future.outer.offset) &&
            (epoch < _calc_rule_epoch(is_leap, result, zone->future.inner.end) - zone->future.inner.offset)) {
            igmtime(epoch + zone->future.inner.offset, result);
            result->isdst  = zone->future.inner.isdst;
            result->n_zone = zone->future.inner.n_abbrev;
            result->gmtoff = zone->future.inner.gmt_offset;
        } else {
            result->isdst  = zone->future.outer.isdst;
            result->n_zone = zone->future.outer.n_abbrev;
            result->gmtoff = zone->future.outer.gmt_offset;
        }
        _PTIME_LT_LEAPSEC_CORR(zone->ltrans);
    }
}

ptime_t timeany (dt* date, const tz* zone) {
#   define PTIME_ANY_NORMALIZE
    if (date->isdst > 0) {
#       undef PTIME_AMBIGUOUS_LATER
#       include <panda/time/timeany_impl.h>
    } else {
#       define PTIME_AMBIGUOUS_LATER
#       include <panda/time/timeany_impl.h>
    }
#   undef PTIME_ANY_NORMALIZE
}

ptime_t timeanyl (dt* date, const tz* zone) {
    if (date->isdst > 0) {
#       undef PTIME_AMBIGUOUS_LATER
#       include <panda/time/timeany_impl.h>
    } else {
#       define PTIME_AMBIGUOUS_LATER
#       include <panda/time/timeany_impl.h>
    }
}

}}
