#ifndef Date_h_included
#define Date_h_included

#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#ifdef __cplusplus
}
#endif
#include "ppport.h"

#include "abstract/include/lib.h"

#define PDATE_WITH_INHERITANCE "DONT ENABLE THIS YET"
#undef PDATE_WITH_INHERITANCE

#define IS_LEAP_YEAR(year) (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0))

static uint8_t days_in_month (int32_t year, uint8_t month) {
    static int days[12] = {31,28,31,30,31,30,31,31,30,31,30,31};
    return days[month-1] + ( (month == 2 && IS_LEAP_YEAR(year)) ? 1 : 0);
}

inline static int num_compare (int64_t a, int64_t b) { return a > b ? 1 : (a == b ? 0 : -1); }
inline static int64_t christ_days (int32_t year) { return year == 0 ? 0 : (year*365 + (year-1)/4 - (year-1)/100 + (year-1)/400 + 1); }

inline static int tm_compare (struct tm& o1, struct tm& o2) {
    int cmp = num_compare(o1.tm_year, o2.tm_year);
    if (cmp != 0) return cmp;
    cmp = num_compare(o1.tm_mon, o2.tm_mon);
    if (cmp != 0) return cmp;
    cmp = num_compare(o1.tm_mday, o2.tm_mday);
    if (cmp != 0) return cmp;
    cmp = num_compare(o1.tm_hour, o2.tm_hour);
    if (cmp != 0) return cmp;
    cmp = num_compare(o1.tm_min, o2.tm_min);
    if (cmp != 0) return cmp;
    return num_compare(o1.tm_sec, o2.tm_sec);
}

#endif
