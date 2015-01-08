#pragma once

bool _tz_lzname (char* lzname) {
    if (
        _from_env(lzname, "SYS$TIMEZONE_RULE") ||
        _from_env(lzname, "SYS$TIMEZONE_NAME") ||
        _from_env(lzname, "UCX$TZ")            ||
        _from_env(lzname, "TCPIP$TZ")
    ) return true;
    return false;
}
