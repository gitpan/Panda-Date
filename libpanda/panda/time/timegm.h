#pragma once

namespace panda { namespace time {

ptime_t timegml (dt* date);
ptime_t timegm  (dt* date);

#ifdef __GNUC__
inline ptime_t itimegmll (const dt* date) __attribute__((always_inline));        
inline ptime_t itimegml  (dt* date)       __attribute__((always_inline));        
inline ptime_t itimegm   (dt* date)       __attribute__((always_inline));        
#endif

inline ptime_t itimegmll (const dt* date) {
    int leap = is_leap_year(date->year);
    ptime_t delta_days = christ_days(date->year) + MON2YDAY[leap][date->mon] + date->mday - 1 - EPOCH_CHRIST_DAYS;
    return delta_days * 86400 + date->hour * 3600 + date->min * 60 + date->sec;
}

inline ptime_t itimegml (dt* date) {
    ptime_t mon_remainder = (date->mon + OUTLIM_MONTH_BY_12) % 12;
    date->year += (date->mon - mon_remainder) / 12;
    date->mon = mon_remainder;
    return itimegmll(date);
}

inline ptime_t itimegm (dt* date) {
    ptime_t result = itimegml(date);
    igmtime(result, date);
    return result;
}

};};
