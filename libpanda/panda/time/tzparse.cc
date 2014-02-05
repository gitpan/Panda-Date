#include <string>
#include <algorithm>
#include <ctype.h>
#include "time.h"
#include "tzparse.h"

namespace panda { namespace time {

#include "tzfile.h"

#undef PTIME_TZPARSE_V1
#undef PTIME_TZPARSE_V2
#define PTIME_TZPARSE_V1
#include "tzparse_format.h"
#undef PTIME_TZPARSE_V1
#define PTIME_TZPARSE_V2
#include "tzparse_format.h"

enum pres_t { PRES_OK, PRES_ABSENT, PRES_ERROR };

static pres_t tzparse_rule_abbrev (const char* &str, char* dest);
static pres_t tzparse_rule_time   (const char* &str, int32_t* dest);
static pres_t tzparse_rule_switch (const char* &str, tzswitch_t* swtype, dt* swdate);

bool tzparse (char* content, tz* zone) {
    char* ptr = content;
    
    ftz_head head;
    int      version;
    int bodyV1_size = tzparse_headerV1(&ptr, head, &version);
    if (bodyV1_size == -1) {
        //fprintf(stderr, "ptime: parsing header V1 failed\n");
        return false;
    }
    
    if (version >= 2) {
        ptr += bodyV1_size;
        if (tzparse_headerV2(&ptr, head, &version) == -1) {
            //fprintf(stderr, "ptime: parsing header V2 failed\n");
            return false;
        }
    }

    bool result = version >= 2 ? tzparse_bodyV2(ptr, head, zone) : tzparse_bodyV1(ptr, head, zone);
    return result;
}

bool tzparse_rule (const char* rulestr, tzrule* rule) {
    if (tzparse_rule_abbrev(rulestr, rule->outer.abbrev) != PRES_OK) return false;
    if (tzparse_rule_time(rulestr, &rule->outer.gmt_offset) != PRES_OK) return false;
    rule->outer.isdst = 0;

    rule->hasdst = 0;
    pres_t result;
    if ((result = tzparse_rule_abbrev(rulestr, rule->inner.abbrev)) == PRES_ERROR) return false;
    if (result == PRES_ABSENT) return *rulestr == '\0';
    
    if ((result = tzparse_rule_time(rulestr, &rule->inner.gmt_offset)) == PRES_ERROR) return false;
    if (result == PRES_ABSENT) rule->inner.gmt_offset = rule->outer.gmt_offset + 3600;
    
    if (*rulestr == ',') {
        rulestr++;
        rule->hasdst = 1;
        rule->inner.isdst = 1;
        
        if (tzparse_rule_switch(rulestr, &rule->outer.type, &rule->outer.end) != PRES_OK) return false;
        if (*rulestr != ',') return false;
        rulestr++;
        if (tzparse_rule_switch(rulestr, &rule->inner.type, &rule->inner.end) != PRES_OK) return false;
        
        if (rule->outer.type != TZSWITCH_DATE || rule->inner.type != TZSWITCH_DATE) {
            //fprintf(stderr, "ptime: tz switch rules other than Mm.w.d (i.e. 'n' or 'Jn') are not supported (will consider no DST in this zone)\n");
            rule->hasdst = 0;
        }
        else if (rule->outer.end.mon > rule->inner.end.mon) {
            std::swap(rule->outer, rule->inner);
        }
    }
    
    return *rulestr == '\0';
}

static pres_t tzparse_rule_abbrev (const char* &str, char* dest) {
    const char* st = str;
    switch (*str) {
        case ':': return PRES_ERROR;
        case '<':
			str++; st = str;
            while (*str && *str != '>') str++;
            if (*str != '>') return PRES_ERROR;
            break;
        default:
            char c;
            while ((c = *str) && !isdigit(c) && c != ',' && c != '+' && c != '-') str++;
    }
    
    size_t len = str - st;
	if (*str == '>') str++;

    if (!len) return PRES_ABSENT;
    if (len < ZONE_ABBR_MIN) return PRES_ERROR;

    strncpy(dest, st, len);
    dest[len] = '\0';
	
    return PRES_OK;
}

static pres_t tzparse_rule_time (const char* &str, int32_t* dest) {
    const char* st = str;
    *dest = - (int32_t) strtol(st, (char**)&str, 10) * 3600;
    if (str == st) return PRES_ABSENT;
    int sign = (*dest >= 0 ? 1 : -1);
    if (*str == ':') {
        str++; st = str;
        *dest += sign * (int32_t) strtol(st, (char**)&str, 10) * 60;
        if (str == st) return PRES_ERROR;
        if (*str == ':') {
            str++; st = str;
            *dest += sign * (int32_t) strtol(st, (char**)&str, 10);
            if (str == st) return PRES_ERROR;
        }
    }

    return PRES_OK;
}

static pres_t tzparse_rule_switch (const char* &str, tzswitch_t* swtype, dt* swdate) {
    bzero(swdate, sizeof(*swdate));
    const char* st = str;
    
    if (*str == 'M') {
        str++; st = str;
        *swtype = TZSWITCH_DATE;
        swdate->mon  = (ptime_t) strtol(st, (char**)&str, 10) - 1;
        if (st == str || swdate->mon < 0 || swdate->mon > 11 || *str != '.') return PRES_ERROR;
        str++; st = str;
        swdate->yday = (int32_t) strtol(st, (char**)&str, 10); // yday holds week number
        if (st == str || swdate->yday < 1 || swdate->yday > 5 || *str != '.') return PRES_ERROR;
        str++; st = str;
        swdate->wday = (int32_t) strtol(st, (char**)&str, 10);
        if (st == str || swdate->wday < 0 || swdate->wday > 6) return PRES_ERROR;
    }
    else if (*str == 'J') {
        *swtype = TZSWITCH_JDAY;
        str++; st = str;
        swdate->yday = (int32_t) strtol(st, (char**)&str, 10);
        if (st == str || swdate->yday < 1 || swdate->yday > 365) return PRES_ERROR;
    } else {
        *swtype = TZSWITCH_DAY;
        swdate->yday = (int32_t) strtol(st, (char**)&str, 10);
        if (st == str || swdate->yday < 0 || swdate->yday > 365) return PRES_ERROR;
    }
    
    if (*str == '/') {
        str++;
        int32_t when;
        if (tzparse_rule_time(str, &when) != PRES_OK) return PRES_ERROR;
        when = -when; // revert reverse behaviour of parsing rule time
        if (when < 0) return PRES_ERROR;
        swdate->hour = when / 3600;
        when %= 3600;
        swdate->min = when / 60;
        swdate->sec = when % 60;
    } else {
        swdate->hour = 2;
        swdate->min  = 0;
        swdate->sec  = 0;
    }
    
    return PRES_OK;
}

}};
