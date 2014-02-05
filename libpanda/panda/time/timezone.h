#pragma once

namespace panda { namespace time {

const int TZNAME_MAX = 255; // max length of timezone name or POSIX rule (Europe/Moscow, ...)

enum tzswitch_t { TZSWITCH_DATE, TZSWITCH_JDAY, TZSWITCH_DAY };

struct tztrans {
    ptime_t start;        // time of transition
    ptime_t local_start;  // local time of transition (epoch+offset).
    ptime_t local_end;    // local time of transition's end (next transition epoch + MY offset).
    ptime_t local_lower;  // local_start or prev transition's local_end
    ptime_t local_upper;  // local_start or prev transition's local_end
    int32_t offset;       // offset from non-leap GMT
    int32_t gmt_offset;   // offset from leap GMT
    int32_t delta;        // offset minus previous transition's offset
    int32_t isdst;        // is DST in effect after this transition
    int32_t leap_corr;    // summary leap seconds correction at the moment
    int32_t leap_delta;   // delta leap seconds correction (0 if it's just a transition, != 0 if it's a leap correction)
    ptime_t leap_end;     // end of leap period (not including last second) = start + leap_delta
    ptime_t leap_lend;    // local_start + 2*leap_delta
    union {
        char    abbrev[ZONE_ABBR_MAX+1]; // transition (zone) abbreviation
        int64_t n_abbrev;                // abbrev as int64_t
    };
};

// rule for future (beyond transition list) dates and for abstract timezones
// http://www.gnu.org/software/libc/manual/html_node/TZ-Variable.html
// --------------------------------------------------------------------------------------------
// 1 Jan   OUTER ZONE   OUTER END        INNER ZONE        INNER END     OUTER ZONE      31 Dec                
// --------------------------------------------------------------------------------------------
struct tzrulezone {
    union {
        char    abbrev[ZONE_ABBR_MAX+1]; // zone abbreviation
        int64_t n_abbrev;                // abbrev as int64_t
    };
    int32_t    offset;                     // offset from non-leap GMT
    int32_t    gmt_offset;                 // offset from leap GMT
    int32_t    isdst;                      // true if zone represents DST time
    tzswitch_t type;                       // type of 'end' field
    dt         end;                        // dynamic date when this zone ends (only if hasdst=1)
};

struct tzrule {
    uint32_t   hasdst;       // does this rule have DST switching
    tzrulezone outer;        // always present
    tzrulezone inner;        // only present if hasdst=1
    int32_t    max_offset;   // max(outer.offset, inner.offset)
    int32_t    delta;        // inner.offset - outer.offset
};

struct tzleap {
    ptime_t  time;
    uint32_t correction;
};

struct tz {
    size_t   refcnt;
    char     name[TZNAME_MAX+1];
    tztrans* trans;
    int32_t  trans_cnt;
    tztrans  ltrans;              // trans[trans_cnt-1]
    tzleap*  leaps;
    int32_t  leaps_cnt;
    tzrule   future;
    bool     is_local;
};

void tzset   (const char* zonename = NULL);
tz*  tzget   (const char*);
tz*  tzlocal ();

const char* tzdir    ();
bool        tzdir    (const char*);
const char* tzsysdir ();

inline void tzcapture (tz* zone) {
    zone->refcnt++;
}

inline void tzfree (tz* zone) {
    if (--zone->refcnt <= 0) {
        delete[] zone->trans;
        if (zone->leaps_cnt > 0) delete[] zone->leaps;
        delete zone;
    }
}

};};
