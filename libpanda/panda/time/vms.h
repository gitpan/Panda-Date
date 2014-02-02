#pragma once

void _tz_lzname (char* lzname) {
    if (
        _from_env(lzname, "TZ")                ||
        _from_env(lzname, "SYS$TIMEZONE_RULE") ||
        _from_env(lzname, "SYS$TIMEZONE_NAME") ||
        _from_env(lzname, "UCX$TZ")            ||
        _from_env(lzname, "TCPIP$TZ")
    ) return;
    strcpy(lzname, PTIME_GMT_FALLBACK);
}
