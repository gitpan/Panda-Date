#pragma once

char* readfile (const char*);

inline int64_t char8_to_int64 (const char* source) {
    return *((int64_t*) source);
}

inline int is_leap_year (int32_t year) {
    return (year % 4) == 0 && ((year % 25) != 0 || (year % 16) == 0);
}

// DAYS PASSED SINCE 1 Jan 0001 00:00:00 TILL 1 Jan <year> 00:00:00
inline ptime_t christ_days (int32_t year) {
    ptime_t yearpos = (ptime_t)year + 2147483999U;
    ptime_t ret = yearpos*365;
    yearpos >>= 2;
    ret += yearpos;
    yearpos /= 25;
    ret -= yearpos - (yearpos >> 2) + (ptime_t)146097*5368710;
    return ret;
}

// GIVEN DAYS PASSED SINCE 1 Jan 0001 00:00:00 CALCULATES REAL YEAR AND DAYS REMAINDER - YDAY [0-365]
inline void christ_year (ptime_t days, int32_t &year, int32_t &remainder) {
    // 1-st step: separate FULL QUAD CENTURIES
    ptime_t tmp = (days + OUTLIM_DAY_BY_QCENT) % DAYS_PER_QCENT;
    year = (days - tmp)/DAYS_PER_QCENT * 400;
    days = tmp;
    
    // 2-nd step: separate FULL CENTURIES, condition fixes QCENT -> CENT border
    if (unlikely(days == DAYS_PER_CENT*4)) {
        year += 300;
        days = DAYS_PER_CENT;
    } else {
        year += days/DAYS_PER_CENT * 100;
        days %= DAYS_PER_CENT;
    }
    
    // 3-rd step: separate FULL QUAD YEARS, no border fix needed
    year += days/DAYS_PER_QYEAR * 4;
    days %= DAYS_PER_QYEAR;
    
    // 4-th step: separate FULL YEARS, condition fixes QYEAR -> YEAR border
    if (unlikely(days == DAYS_PER_YEAR*4)) {
        year += 4; // actually 3, but we must add 1 to result year, as the start is 1-st year, not 0-th
        remainder = 365;
    } else {
        year += days/DAYS_PER_YEAR + 1; // we must add 1 to result year, as the start is 1-st year, not 0-th
        remainder = days % DAYS_PER_YEAR;
    }
}

inline void dt2tm (struct tm &to, dt &from) {
    to.tm_sec    = from.sec;
    to.tm_min    = from.min;
    to.tm_hour   = from.hour;
    to.tm_mday   = from.mday;
    to.tm_mon    = from.mon;
    to.tm_year   = from.year-1900;
    to.tm_isdst  = from.isdst;
    to.tm_wday   = from.wday;
    to.tm_yday   = from.yday;
#ifndef PTIME_OSTYPE_WIN	
    to.tm_gmtoff = from.gmtoff;
    to.tm_zone   = from.zone;
#endif
}

inline void tm2dt (dt &to, struct tm &from) {
    to.sec    = from.tm_sec;
    to.min    = from.tm_min;
    to.hour   = from.tm_hour;
    to.mday   = from.tm_mday;
    to.mon    = from.tm_mon;
    to.year   = from.tm_year+1900;
    to.isdst  = from.tm_isdst;
    to.wday   = from.tm_wday;
    to.yday   = from.tm_yday;
#ifdef PTIME_OSTYPE_WIN
	to.gmtoff = 0;
	to.n_zone = 0;
#else
    to.gmtoff = from.tm_gmtoff;
    to.n_zone = char8_to_int64(from.tm_zone);
#endif
}

inline int days_in_month (int32_t year, uint8_t month) {
    return DAYS_IN_MONTH[is_leap_year(year)][month];
}
