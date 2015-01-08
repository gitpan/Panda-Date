#pragma once
#include <string>
#include <windows.h>

using std::string;

struct win_tzpair {
    char win_name[32];
    char olson_name[31];
};

static const win_tzpair translist[] = {
    {"AUS Central", "Australia/Darwin"},
    {"AUS Central Standard Time", "Australia/Darwin"},
    {"AUS Eastern", "Australia/Sydney"},
    {"AUS Eastern Standard Time", "Australia/Sydney"},
    {"Afghanistan", "Asia/Kabul"},
    {"Afghanistan Standard Time", "Asia/Kabul"},
    {"Alaskan", "America/Anchorage"},
    {"Alaskan Standard Time", "America/Anchorage"},
    {"Arab", "Asia/Riyadh"},
    {"Arab Standard Time", "Asia/Riyadh"},
    {"Arabian", "Asia/Muscat"},
    {"Arabian Standard Time", "Asia/Muscat"},
    {"Arabic Standard Time", "Asia/Baghdad"},
    {"Argentina Standard Time", "America/Argentina/Buenos_Aires"},
    {"Armenian Standard Time", "Asia/Yerevan"},
    {"Atlantic", "America/Halifax"},
    {"Atlantic Standard Time", "America/Halifax"},
    {"Azerbaijan Standard Time", "Asia/Baku"},
    {"Azores", "Atlantic/Azores"},
    {"Azores Standard Time", "Atlantic/Azores"},
    {"Bahia Standard Time", "America/Bahia"},
    {"Bangkok", "Asia/Bangkok"},
    {"Bangkok Standard Time", "Asia/Bangkok"},
    {"Bangladesh Standard Time", "Asia/Dhaka"},
    {"Beijing", "Asia/Shanghai"},
    {"Canada Central", "America/Regina"},
    {"Canada Central Standard Time", "America/Regina"},
    {"Cape Verde Standard Time", "Atlantic/Cape_Verde"},
    {"Caucasus", "Asia/Yerevan"},
    {"Caucasus Standard Time", "Asia/Yerevan"},
    {"Cen. Australia", "Australia/Adelaide"},
    {"Cen. Australia Standard Time", "Australia/Adelaide"},
    {"Central", "America/Chicago"},
    {"Central America Standard Time", "America/Regina"},
    {"Central Asia", "Asia/Almaty"},
    {"Central Asia Standard Time", "Asia/Almaty"},
    {"Central Brazilian Standard Time", "America/Cuiaba"},
    {"Central Europe", "Europe/Prague"},
    {"Central Europe Standard Time", "Europe/Prague"},
    {"Central European", "Europe/Belgrade"},
    {"Central European Standard Time", "Europe/Belgrade"},
    {"Central Pacific", "Pacific/Guadalcanal"},
    {"Central Pacific Standard Time", "Pacific/Guadalcanal"},
    {"Central Standard Time", "America/Chicago"},
    {"Central Standard Time (Mexico)", "America/Mexico_City"},
    {"China", "Asia/Shanghai"},
    {"China Standard Time", "Asia/Shanghai"},
    {"Dateline", "UTC-12"},
    {"Dateline Standard Time", "UTC-12"},
    {"E. Africa", "Africa/Nairobi"},
    {"E. Africa Standard Time", "Africa/Nairobi"},
    {"E. Australia", "Australia/Brisbane"},
    {"E. Australia Standard Time", "Australia/Brisbane"},
    {"E. Europe", "Europe/Minsk"},
    {"E. Europe Standard Time", "Europe/Minsk"},
    {"E. South America", "America/Sao_Paulo"},
    {"E. South America Standard Time", "America/Sao_Paulo"},
    {"Eastern", "America/New_York"},
    {"Eastern Standard Time", "America/New_York"},
    {"Egypt", "Africa/Cairo"},
    {"Egypt Standard Time", "Africa/Cairo"},
    {"Ekaterinburg", "Asia/Yekaterinburg"},
    {"Ekaterinburg Standard Time", "Asia/Yekaterinburg"},
    {"FLE", "Europe/Helsinki"},
    {"FLE Standard Time", "Europe/Helsinki"},
    {"Fiji", "Pacific/Fiji"},
    {"Fiji Standard Time", "Pacific/Fiji"},
    {"GFT", "Europe/Athens"},
    {"GFT Standard Time", "Europe/Athens"},
    {"GMT", "Europe/London"},
    {"GMT Standard Time", "Europe/London"},
    {"GTB", "Europe/Athens"},
    {"GTB Standard Time", "Europe/Athens"},
    {"Georgian Standard Time", "Asia/Tbilisi"},
    {"Greenland Standard Time", "America/Godthab"},
    {"Greenwich", "GMT"},
    {"Greenwich Standard Time", "GMT"},
    {"Hawaiian", "Pacific/Honolulu"},
    {"Hawaiian Standard Time", "Pacific/Honolulu"},
    {"India", "Asia/Calcutta"},
    {"India Standard Time", "Asia/Calcutta"},
    {"Iran", "Asia/Tehran"},
    {"Iran Standard Time", "Asia/Tehran"},
    {"Israel", "Asia/Jerusalem"},
    {"Israel Standard Time", "Asia/Jerusalem"},
    {"Jordan Standard Time", "Asia/Amman"},
    {"Kaliningrad Standard Time", "Europe/Kaliningrad"},
    {"Kamchatka Standard Time", "Asia/Kamchatka"},
    {"Korea", "Asia/Seoul"},
    {"Korea Standard Time", "Asia/Seoul"},
    {"Magadan Standard Time", "Asia/Magadan"},
    {"Mauritius Standard Time", "Indian/Mauritius"},
    {"Mexico", "America/Mexico_City"},
    {"Mexico Standard Time", "America/Mexico_City"},
    {"Mexico Standard Time 2", "America/Chihuahua"},
    {"Mid-Atlantic", "Atlantic/South_Georgia"},
    {"Mid-Atlantic Standard Time", "Atlantic/South_Georgia"},
    {"Middle East Standard Time", "Asia/Beirut"},
    {"Montevideo Standard Time", "America/Montevideo"},
    {"Morocco Standard Time", "Africa/Casablanca"},
    {"Mountain", "America/Denver"},
    {"Mountain Standard Time", "America/Denver"},
    {"Mountain Standard Time (Mexico)", "America/Chihuahua"},
    {"Myanmar Standard Time", "Asia/Rangoon"},
    {"N. Central Asia Standard Time", "Asia/Novosibirsk"},
    {"Namibia Standard Time", "Africa/Windhoek"},
    {"Nepal Standard Time", "Asia/Katmandu"},
    {"New Zealand", "Pacific/Auckland"},
    {"New Zealand Standard Time", "Pacific/Auckland"},
    {"Newfoundland", "America/St_Johns"},
    {"Newfoundland Standard Time", "America/St_Johns"},
    {"North Asia East Standard Time", "Asia/Irkutsk"},
    {"North Asia Standard Time", "Asia/Krasnoyarsk"},
    {"Pacific", "America/Los_Angeles"},
    {"Pacific SA", "America/Santiago"},
    {"Pacific SA Standard Time", "America/Santiago"},
    {"Pacific Standard Time", "America/Los_Angeles"},
    {"Pacific Standard Time (Mexico)", "America/Tijuana"},
    {"Pakistan Standard Time", "Asia/Karachi"},
    {"Paraguay Standard Time", "America/Asuncion"},
    {"Prague Bratislava", "Europe/Prague"},
    {"Romance", "Europe/Paris"},
    {"Romance Standard Time", "Europe/Paris"},
    {"Russian", "Europe/Moscow"},
    {"Russian Standard Time", "Europe/Moscow"},
    {"SA Eastern", "America/Cayenne"},
    {"SA Eastern Standard Time", "America/Cayenne"},
    {"SA Pacific", "America/Bogota"},
    {"SA Pacific Standard Time", "America/Bogota"},
    {"SA Western", "America/Guyana"},
    {"SA Western Standard Time", "America/Guyana"},
    {"SE Asia", "Asia/Bangkok"},
    {"SE Asia Standard Time", "Asia/Bangkok"},
    {"Samoa", "Pacific/Apia"},
    {"Samoa Standard Time", "Pacific/Apia"},
    {"Saudi Arabia", "Asia/Riyadh"},
    {"Saudi Arabia Standard Time", "Asia/Riyadh"},
    {"Singapore", "Asia/Singapore"},
    {"Singapore Standard Time", "Asia/Singapore"},
    {"South Africa", "Africa/Harare"},
    {"South Africa Standard Time", "Africa/Harare"},
    {"Sri Lanka", "Asia/Colombo"},
    {"Sri Lanka Standard Time", "Asia/Colombo"},
    {"Sydney Standard Time", "Australia/Sydney"},
    {"Syria Standard Time", "Asia/Damascus"},
    {"Taipei", "Asia/Taipei"},
    {"Taipei Standard Time", "Asia/Taipei"},
    {"Tasmania", "Australia/Hobart"},
    {"Tasmania Standard Time", "Australia/Hobart"},
    {"Tokyo", "Asia/Tokyo"},
    {"Tokyo Standard Time", "Asia/Tokyo"},
    {"Tonga Standard Time", "Pacific/Tongatapu"},
    {"Turkey Standard Time", "Europe/Istanbul"},
    {"US Eastern", "America/Indianapolis"},
    {"US Eastern Standard Time", "America/Indianapolis"},
    {"US Mountain", "America/Phoenix"},
    {"US Mountain Standard Time", "America/Phoenix"},
    {"UTC", "UTC"},
    {"UTC+12", "UTC+12"},
    {"UTC-02", "UTC-2"},
    {"UTC-11", "UTC-11"},
    {"Ulaanbaatar Standard Time", "Asia/Ulaanbaatar"},
    {"Venezuela Standard Time", "America/Caracas"},
    {"Vladivostok", "Asia/Vladivostok"},
    {"Vladivostok Standard Time", "Asia/Vladivostok"},
    {"W. Australia", "Australia/Perth"},
    {"W. Australia Standard Time", "Australia/Perth"},
    {"W. Central Africa Standard Time", "Africa/Luanda"},
    {"W. Europe", "Europe/Berlin"},
    {"W. Europe Standard Time", "Europe/Berlin"},
    {"Warsaw", "Europe/Warsaw"},
    {"West Asia", "Asia/Karachi"},
    {"West Asia Standard Time", "Asia/Karachi"},
    {"West Pacific", "Pacific/Guam"},
    {"West Pacific Standard Time", "Pacific/Guam"},
    {"Western Brazilian Standard Time", "America/Rio_Branco"},
    {"Yakutsk", "Asia/Yakutsk"},
    {"Yakutsk Standard Time", "Asia/Yakutsk"}
};

int _win_tzpair_cmp(const void* p1, const void* p2) {
	return strcmp(((win_tzpair*)p1)->win_name, ((win_tzpair*)p2)->win_name);
}

const char* _win2olson (const char* win_name) {
    win_tzpair pair;
	if (strlen(win_name) >= sizeof(pair.win_name)) return NULL;
	strcpy(pair.win_name, win_name);
	win_tzpair* entry = (win_tzpair*) bsearch(
	    &pair, translist, sizeof(translist) / sizeof(translist[0]), sizeof(translist[0]), _win_tzpair_cmp
	);
	if (!entry) return NULL;
	return entry->olson_name;
}

void _winerr (const char* prefix, LONG error) {
    LPTSTR errorText = NULL;
	FormatMessage(
        FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_IGNORE_INSERTS,  
        NULL,
        error,
        MAKELANGID(LANG_ENGLISH, SUBLANG_DEFAULT),
        (LPTSTR)&errorText,
        0,
        NULL
    );
    printf("_winerr: %s: %s\n", prefix, errorText);
}

bool _win_get_regkey (const char* key, HKEY* result, REGSAM flags) {
    return RegOpenKeyEx(HKEY_LOCAL_MACHINE, key, 0, flags, result) == ERROR_SUCCESS; // no key
}

bool _win_get_regkeyval (HKEY* hkey, const char* name, string* result) {
    DWORD type, cbData;
    if (RegQueryValueEx(*hkey, name, NULL, &type, NULL, &cbData) != ERROR_SUCCESS) return false; // no param 'name' under key
    if (type != REG_SZ) return false; // Incorrect registry value type

    string value(cbData, '\0');
    if (RegQueryValueEx(*hkey, name, NULL, NULL, reinterpret_cast<LPBYTE>(&value[0]), &cbData) != ERROR_SUCCESS) return false; // Could not read registry value

    size_t firstNull = value.find_first_of('\0');
    if (firstNull != string::npos) value.resize(firstNull);

	*result = value;
    return true;
}

bool _win_get_regval (const char* key, const char* name, string* result) {
    HKEY hkey;
	if (!_win_get_regkey(key, &hkey, KEY_READ)) return false;
	bool retval = _win_get_regkeyval(&hkey, name, result);
	RegCloseKey(hkey);
	return retval;
}

bool _win_get_tzname_by_stzname (string stzname, string* tzname) {
	HKEY hkey;
	REGSAM mode = KEY_READ | KEY_ENUMERATE_SUB_KEYS | KEY_QUERY_VALUE;
	string root = "SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Time Zones"; // NT, 2000, XP, 2003 Server
	if (!_win_get_regkey(root.c_str(), &hkey, mode)) {
	    root = "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Time Zones"; // 95, 98, Millenium Edition
		if (!_win_get_regkey(root.c_str(), &hkey, mode)) return false;
    }    
		
	DWORD nsubkeys, subkey_maxlen;
	if (RegQueryInfoKey(hkey, NULL, NULL, NULL, &nsubkeys, &subkey_maxlen, NULL, NULL, NULL, NULL, NULL, NULL) != ERROR_SUCCESS) {
		RegCloseKey(hkey);
		return false;
	}
	++subkey_maxlen;
	
	bool found = false;
	char* subkey_name = new char[subkey_maxlen];
	for (DWORD i = 0; i < nsubkeys; ++i) {
		DWORD subkey_len = subkey_maxlen;
	    if (RegEnumKeyEx(hkey, i, subkey_name, &subkey_len, NULL, NULL, NULL, NULL) != ERROR_SUCCESS) {
			RegCloseKey(hkey);
			return false;
		}
		
		string subkey_path = root + "\\" + subkey_name;
		HKEY subkey;
		if (!_win_get_regkey(subkey_path.c_str(), &subkey, KEY_READ)) continue;
		
		string curstzname;
		bool retval = _win_get_regkeyval(&subkey, "Std", &curstzname);
		RegCloseKey(subkey);
		
		printf("RETVAL=%d\n", retval);
		printf("CHECKING %s with %s\n", stzname.c_str(), curstzname.c_str());
		if (retval && curstzname == stzname) {
			found = true;
			break;
		}
	}

	if (found) *tzname = string(subkey_name);
	delete[] subkey_name;
	RegCloseKey(hkey);
	return found;
}

bool _from_registry (char* lzname) {
    string tzname;
	const char* reg_lzpath = "SYSTEM\\CurrentControlSet\\Control\\TimeZoneInformation";
	
	if (!_win_get_regval(reg_lzpath, "TimeZoneKeyName", &tzname)) { // Vista, 2008 Server and later
		string stzname;
		if (!_win_get_regval(reg_lzpath, "StandardName", &stzname)) return false;
		if (stzname.length() < 1) return false;
		if (!_win_get_tzname_by_stzname(stzname, &tzname)) return false;
	}
	
	const char* olson_name = _win2olson(tzname.c_str());
	if (!olson_name) return false;
	
	strcpy(lzname, olson_name);
	return true;
}

bool _tz_lzname (char* lzname) {
    if (_from_registry(lzname)) return true;
    return false;
}
