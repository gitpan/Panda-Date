#pragma once

namespace panda { namespace time {

void gmtime (ptime_t epoch, dt* result);

#ifdef __GNUC__
inline void igmtime (ptime_t epoch, dt* result) __attribute__((always_inline));        
#endif

inline void igmtime (ptime_t epoch, dt* result) {
    ptime_t sec_remainder = (epoch + OUTLIM_EPOCH_BY_86400) % 86400;
    ptime_t delta_days = (epoch - sec_remainder)/86400;
    result->wday = (OUTLIM_DAY_BY_7 + EPOCH_WDAY + delta_days) % 7;
    result->hour = sec_remainder/3600;
    sec_remainder %= 3600;
    result->min = sec_remainder/60;
    result->sec = sec_remainder % 60;

    int32_t year;
    int32_t remainder;
    christ_year(EPOCH_CHRIST_DAYS + delta_days, year, remainder);
    
    int leap = is_leap_year(year);
    result->yday = remainder;
    result->mon  = YDAY2MON[leap][remainder];
    result->mday = YDAY2MDAY[leap][remainder];
    result->gmtoff = 0;
    result->n_zone = ZONE_N_GMT;
    result->isdst = 0;
    result->year = year;
}

};};
