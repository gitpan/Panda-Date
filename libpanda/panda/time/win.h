#pragma once

bool _from_registry (char* lzname) {
	return false;
}

void _tz_lzname (char* lzname) {
    if (_from_env(lzname, "TZ") || _from_registry(lzname)) return;
    strcpy(lzname, PTIME_GMT_FALLBACK);
}
