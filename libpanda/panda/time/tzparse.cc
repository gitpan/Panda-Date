#include <string>
#include <algorithm>
#include <regex.h>
#include <netinet/in.h>
#include "time.h"
#include <ctype.h>

namespace panda { namespace time {

const std::string re_abbrev     = "(<([^>]+)>|[a-zA-Z]+)";
const int         re_abbrev_cnt = 2;
const std::string re_offset     = "\\+?(-?[0-9]+)(:([0-9]+)(:([0-9]+))?)?";
const int         re_offset_cnt = 5;
const std::string re_switch     = ",(M([0-9]+)\\.([0-9]+)\\.([0-9]+)|(J)?([0-9]+))(/([0-9]+)(:([0-9]+)(:([0-9]+))?)?)?";
const int         re_switch_cnt = 12;
const std::string re_pattern    = 
    "^" + re_abbrev + re_offset + "(" + 
        re_abbrev + "(" + re_offset + ")?" + re_switch + re_switch +
    ")?";
regex_t pattern;
bool    pattern_compiled;

bool    _tzparse_rule_abbrev (const char*, regmatch_t*, char*);
int32_t _tzparse_rule_time   (const char*, regmatch_t*);
bool    _tzparse_rule_switch (const char*, regmatch_t*, int32_t*, dt*);
void    _dump_matches        (const char*, regmatch_t*, size_t n);

#include "tzparse_format.h"
#define PTIME_TZPARSE_V2
#include "tzparse_format.h"

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

inline void _tzparse_skip_spaces (const char* &str) { while (isspace(*str)) str++; }

/*
const enum pres_t { PRES_OK, PRES_ABSENT, PRES_ERROR };

bool tzparse_rule2 (const char* rulestr, tzrule& rule) {
    //_tzparse_skip_spaces(rulestr);
    if (!_tzparse_rule_abbrev2(rulestr, rule.outer.abbrev)) return false;
    //_tzparse_skip_spaces(rulestr);
    
    rule.outer.gmt_offset = _tzparse_rule_time(rulestr, m);
    m += re_offset_cnt;

    rule.outer.isdst = 0;
    
    rule.hasdst = m->rm_so == -1 ? 0 : 1; // conditional braces of all rest block
    m++;
    
    if (rule.hasdst) {
        if (!_tzparse_rule_abbrev(rulestr, m, rule.inner.abbrev)) return false;
        m += re_abbrev_cnt;
        
        // conditional braces before dst offset
        if ((m++)->rm_so != -1) rule.inner.gmt_offset = _tzparse_rule_time(rulestr, m);
        else rule.inner.gmt_offset = rule.outer.gmt_offset + 3600;
        m += re_offset_cnt;
        
        int32_t oswtype, iswtype;
        if (!_tzparse_rule_switch(rulestr, m, &oswtype, &rule.outer.end)) return false;
        m += re_switch_cnt;
        if (!_tzparse_rule_switch(rulestr, m, &iswtype, &rule.inner.end)) return false;
        m += re_switch_cnt;
        
        rule.inner.isdst = 1;
        
        if (oswtype != TZSWITCH_DATE || iswtype != TZSWITCH_DATE) {
            //fprintf(stderr, "ptime: tz switch rules other than Mm.w.d (i.e. 'n' or 'Jn') are not supported (will consider no DST in this zone)\n");
            rule.hasdst = 0;
        }
        else if (rule.outer.end.mon > rule.inner.end.mon) { // southern hemisphere
            std::swap(rule.outer, rule.inner);
        }
    }
    
    return true;
}









pres_t _tzparse_rule_abbrev2 (const char* &str, char* dest) {
    switch (*str) {
        case ':': return PRES_ERROR;
        case '<':
            while (*str && *str != '>') str++;
            if (*str == '>') str++;
            else return PRES_ERROR;
            break;
        default:
            char c;
            while ((c = *str) && !isdigit(c) && c != ',' && c != '+' && c != '-') str++;
            
    }
    
    size_t len = ptr-str;
    if (!len) return 0;

    strncpy(dest, str, len);
    dest[len] = '\0';
    return len;
}

size_t _tzparse_rule_time2 (const char* str, int32_t* dest) {
    const char* ptr;
    *dest = - (int32_t) strtol(str, &ptr, 10) * 3600;
    int sign = (*dest >= 0 ? 1 : -1);
    if (*ptr == ':') {
        str = ptr+1;
        *dest += sign * (int32_t) strtol(str, &ptr, 10) * 60;
        if (*ptr == ':') {
            str = ptr+1;
            *dest += sign * (int32_t) strtol(str, &ptr, 10);
        }
    }
    
    return ptr-str;
}

*/








bool tzparse_rule (const char* rulestr, tzrule& rule) {
    if (!pattern_compiled) {
        int err = regcomp(&pattern, re_pattern.c_str(), REG_EXTENDED);
        assert(err == 0);
        pattern_compiled = true;
    }
    
    size_t n = 50;
    regmatch_t matches[n];
    int err = regexec(&pattern, rulestr, n, matches, 0);

    if (err != 0) {
        //fprintf(stderr, "ptime: regexp hasn't matched, rule = %s\n", rulestr);
        return false;
    }
    regmatch_t* m = matches+1;
    //_dump_matches(rulestr, matches, n);

    if (!_tzparse_rule_abbrev(rulestr, m, rule.outer.abbrev)) return false;
    m += re_abbrev_cnt;
    
    rule.outer.gmt_offset = _tzparse_rule_time(rulestr, m);
    m += re_offset_cnt;

    rule.outer.isdst = 0;
    
    rule.hasdst = m->rm_so == -1 ? 0 : 1; // conditional braces of all rest block
    m++;
    
    if (rule.hasdst) {
        if (!_tzparse_rule_abbrev(rulestr, m, rule.inner.abbrev)) return false;
        m += re_abbrev_cnt;
        
        // conditional braces before dst offset
        if ((m++)->rm_so != -1) rule.inner.gmt_offset = _tzparse_rule_time(rulestr, m);
        else rule.inner.gmt_offset = rule.outer.gmt_offset + 3600;
        m += re_offset_cnt;
        
        int32_t oswtype, iswtype;
        if (!_tzparse_rule_switch(rulestr, m, &oswtype, &rule.outer.end)) return false;
        m += re_switch_cnt;
        if (!_tzparse_rule_switch(rulestr, m, &iswtype, &rule.inner.end)) return false;
        m += re_switch_cnt;
        
        rule.inner.isdst = 1;
        
        if (oswtype != TZSWITCH_DATE || iswtype != TZSWITCH_DATE) {
            //fprintf(stderr, "ptime: tz switch rules other than Mm.w.d (i.e. 'n' or 'Jn') are not supported (will consider no DST in this zone)\n");
            rule.hasdst = 0;
        }
        else if (rule.outer.end.mon > rule.inner.end.mon) { // southern hemisphere
            std::swap(rule.outer, rule.inner);
        }
    }
    
    return true;
}

bool _tzparse_rule_abbrev (const char* str, regmatch_t* m, char* dest) {
    if (m[1].rm_so != -1) m++; // quoted match, use inner braces
    size_t len = m->rm_eo - m->rm_so;
    if (len > ZONE_ABBR_MAX) return false;
    strncpy(dest, str + m->rm_so, len);
    dest[len] = '\0';
    return true;
}

int32_t _tzparse_rule_time (const char* str, regmatch_t* m) {
    int32_t val = - (int32_t) strtol(str + m[0].rm_so, NULL, 10) * 3600;
    if (m[2].rm_so != -1) { // offset mins[secs]
        val += (val >= 0 ? 1 : -1) * (int32_t) strtol(str + m[2].rm_so, NULL, 10) * 60;
        if (m[4].rm_so != -1) val += (val >= 0 ? 1 : -1) * (int32_t) strtol(str + m[4].rm_so, NULL, 10);
    }
    return val;
}

bool _tzparse_rule_switch (const char* str, regmatch_t* m, int32_t* swtype, dt* swdate) {
    bzero(swdate, sizeof(*swdate));
    
    if (m[1].rm_so != -1) {
        *swtype = TZSWITCH_DATE;
        swdate->mon  = (ptime_t) strtol(str + m[1].rm_so, NULL, 10) - 1;
        swdate->yday = (int32_t) strtol(str + m[2].rm_so, NULL, 10); // yday holds week number
        swdate->wday = (int32_t) strtol(str + m[3].rm_so, NULL, 10);
    }
    else {
        *swtype = m[4].rm_so == -1 ? TZSWITCH_DAY : TZSWITCH_JDAY;
        swdate->yday = (int32_t) strtol(str + m[5].rm_so, NULL, 10);
    }
    
    if (m[7].rm_so != -1) {
        swdate->hour = (ptime_t) strtol(str + m[7].rm_so, NULL, 10);
        if (m[9].rm_so != -1)  swdate->min = (ptime_t) strtol(str + m[9].rm_so, NULL, 10);
        if (m[11].rm_so != -1) swdate->sec = (ptime_t) strtol(str + m[11].rm_so, NULL, 10);
    } else {
        swdate->hour = 2;
        swdate->min  = 0;
        swdate->sec  = 0;
    }
    
    return true;
}

void _dump_matches (const char* str, regmatch_t* m, size_t n) {
    for (int i = 0; i < n; i++) {
        if (m[i].rm_so == -1) printf("%d: no match\n", i);
        else {
            char buf[10000];
            strncpy(buf, str+m[i].rm_so, m[i].rm_eo - m[i].rm_so);
            buf[m[i].rm_eo - m[i].rm_so] = '\0';
            printf("%d: %s\n", i, buf);
        }
    }
}



}};
