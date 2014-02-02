#pragma once

#include <regex.h>

bool _from_etc_localtime (char* lzname) {
    if (access("/etc/localtime", R_OK) != 0) return false;
    strcpy(lzname, ":/etc/localtime");
    return true;
}

bool _from_usr_local_etc_localtime (char* lzname) {
    if (access("/usr/local/etc/localtime", R_OK) != 0) return false;
    strcpy(lzname, ":/usr/local/etc/localtime");
    return true;
}

bool _from_regex (char* lzname, const char* filename, regex_t* pattern, int nmatch) {
    char* content = readfile(filename);
    if (content == NULL) return false;
    
    regmatch_t m[10];
    if (regexec(pattern, content, 10, m, 0) != 0) { // no match
        delete[] content;
        return false;
    }
    
    size_t len = m[nmatch].rm_eo - m[nmatch].rm_so;
    if (len < 1 || len > TZNAME_MAX) return false;
    
    strncpy(lzname, content + m[nmatch].rm_so, len);
    lzname[len] = '\0';
    delete[] content;
    return true;
}

bool _from_etc_timezone (char* lzname) {
    regex_t pattern;
    int err = regcomp(&pattern, "([^[:space:]]+)", REG_EXTENDED|REG_NEWLINE);
    assert(err == 0);
    return _from_regex(lzname, "/etc/timezone", &pattern, 1);
}

bool _from_etc_TIMEZONE (char* lzname) {
    regex_t pattern;
    int err = regcomp(&pattern, "^[[:space:]]*TZ[[:space:]]*=[[:space:]]*([^[:space:]]+)", REG_EXTENDED|REG_NEWLINE);
    assert(err == 0);
    return _from_regex(lzname, "/etc/TIMEZONE", &pattern, 1);
}

bool _from_etc_sysconfig_clock (char* lzname) {
    regex_t pattern;
    int err = regcomp(&pattern, "^[[:space:]]*(TIME)?ZONE[[:space:]]*=[[:space:]]*\"([^\"]+)\"", REG_EXTENDED|REG_NEWLINE);
    assert(err == 0);
    return _from_regex(lzname, "/etc/sysconfig/clock", &pattern, 2);
}

bool _from_etc_default_init (char* lzname) {
    regex_t pattern;
    int err = regcomp(&pattern, "^[[:space:]]*TZ[[:space:]]*=[[:space:]]*([^[:space:]]+)", REG_EXTENDED|REG_NEWLINE);
    assert(err == 0);
    return _from_regex(lzname, "/etc/default/init", &pattern, 1);
}

void _tz_lzname (char* lzname) {
    if (
        _from_env(lzname, "TZ")               ||
        _from_etc_localtime(lzname)           ||
        _from_usr_local_etc_localtime(lzname) ||
        _from_etc_timezone(lzname)            ||
        _from_etc_TIMEZONE(lzname)            ||
        _from_etc_sysconfig_clock(lzname)     ||
        _from_etc_default_init(lzname)
    ) return;
    strcpy(lzname, PTIME_GMT_FALLBACK);
}
