#include <map>
#include "time.h"
#include "../util.h"
#include <vector>

using panda::util::string_hash;

namespace panda { namespace time {

typedef std::map<uint64_t, tz*> Zones;

typedef std::vector<tz*> _vzone;
static  _vzone _dbgzones;

static Zones _tzcache;
static tz*   _localzone = NULL;
static char  _tzdir[ZONE_PATH_MAX+1];
static bool  _tzdir_set = false;

static tz*  _tzget            (const char* zonename);
static bool _virtual_zone     (const char* zonename, tz* zone);
static void _virtual_fallback (tz* zone);
static void _tzcache_clear    ();

tz* tzlocal () {
    if (_localzone == NULL) tzset();
    return _localzone;
}

tz* tzget (const char* zonename) {
    if (zonename == NULL || zonename[0] == '\0') return tzlocal();
    else {
        uint64_t hashval = string_hash(zonename, strlen(zonename));
        Zones::iterator it = _tzcache.find(hashval);
        if (it == _tzcache.end()) {
            tz* zone = _tzget(zonename);
            _tzcache[hashval] = zone;
            return zone;
        }
        else return it->second;
    }
}

void tzset (const char* zonename) {
    if (_localzone != NULL) tzfree(_localzone);
    _localzone = _tzget(zonename);
    _localzone->is_local = true;
}

const char* tzdir () {
    if (_tzdir_set) return _tzdir;
    return tzsysdir();
}

bool tzdir (const char* dir) {
    _tzcache_clear();

    if (dir == NULL) {
        _tzdir_set = false;
        return true;
    }
    else if (strlen(dir) > ZONE_PATH_MAX) return false;
    
    _tzdir_set = true;
    strcpy(_tzdir, dir);
    return true;
}

const char* tzsysdir () {
    return PTIME_ZONEDIR;
}

static int lastid = 0;

tz* _tzget (const char* zonename) {
    //printf("ptime: tzget for zone %s\n", zonename);
    tz* zone = (tz*) malloc(sizeof(tz));
    assert(zone != NULL);
    zone->refcnt = 1;
    zone->is_local = false;
    zone->id = ++lastid;
    
    //_dbgzones.push_back(zone);
    //tzcapture(zone);
    
    if (zonename == NULL || zonename[0] == '\0') {
        char lzname[TZNAME_MAX+1];
        _tz_lzname(lzname);
        zonename = lzname;
        zone->is_local = true;
    }
    assert(zonename != NULL);
    
    if (strlen(zonename) > TZNAME_MAX) { 
        //fprintf(stderr, "ptime: tzrule too long\n");
        _virtual_fallback(zone);
        return zone;
    }

    std::string filename;
    if (zonename[0] == ':') {
        filename.assign(zonename+1);
        strcpy(zone->name, zonename);
    }
    else {
        const char* dir = tzdir();
        if (dir == NULL) {
            fprintf(stderr, "ptime: tzget: this OS has no olson timezone files, you must explicitly set tzdir(DIR)\n");
            _virtual_fallback(zone);
            return zone;
        }
        strcpy(zone->name, zonename);
        filename.assign(dir);
        filename.append("/");
        filename.append(zonename);
    }
    
    const char* cfilename = filename.c_str();
    char* content = readfile(cfilename);

    if (content == NULL) { // tz rule
        //printf("ptime: tzget rule %s\n", zonename);
        if (!_virtual_zone(zonename, zone)) {
            //fprintf(stderr, "ptime: parsing rule '%s' failed\n", zonename);
            _virtual_fallback(zone);
            return zone;
        }
    }
    else { // tz file
        //printf("ptime: tzget file %s\n", filename.c_str());
        bool result = tzparse(content, zone);
        delete[] content;
        if (!result) {
            //fprintf(stderr, "ptime: parsing file '%s' failed\n", filename.c_str());
            _virtual_fallback(zone);
            return zone;
        }
    }
    
    return zone;
}

void _virtual_fallback (tz* zone) {
    //fprintf(stderr, "ptime: fallback to '%s'\n", PTIME_GMT_FALLBACK);
    assert(_virtual_zone(PTIME_GMT_FALLBACK, zone) == true);
    strcpy(zone->name, PTIME_GMT_FALLBACK);
    zone->is_local = false;
}

bool _virtual_zone (const char* zonename, tz* zone) {
    //printf("ptime: virtual zone %s\n", zonename);
    if (!tzparse_rule(zonename, zone->future)) return false;
    zone->future.outer.offset = zone->future.outer.gmt_offset;
    zone->future.inner.offset = zone->future.inner.gmt_offset;
    zone->future.delta        = zone->future.inner.offset - zone->future.outer.offset;
    zone->future.max_offset   = std::max(zone->future.outer.offset, zone->future.inner.offset);
    
    zone->leaps_cnt = 0;
    zone->leaps = NULL;
    zone->trans_cnt = 1;
    size_t trans_size = zone->trans_cnt * sizeof(tztrans);
    zone->trans = (tztrans*) malloc(trans_size);
    bzero(zone->trans, trans_size);
    zone->trans[0].start       = EPOCH_NEGINF;
    zone->trans[0].local_start = EPOCH_NEGINF;
    zone->trans[0].local_lower = EPOCH_NEGINF;
    zone->trans[0].local_upper = EPOCH_NEGINF;
    zone->trans[0].leap_corr   = 0;
    zone->trans[0].leap_delta  = 0;
    zone->trans[0].leap_end    = EPOCH_NEGINF;
    zone->trans[0].leap_lend   = EPOCH_NEGINF;
    zone->ltrans = zone->trans[0];
    return true;
}

void _tzcache_clear () {
    Zones::iterator it;
    for (it = _tzcache.begin(); it != _tzcache.end(); it++) tzfree(it->second);
    _tzcache.clear();
}

void dump_zones () {
    printf("----------------- REPORT ----------------\n");
    for (_vzone::iterator it = _dbgzones.begin(); it != _dbgzones.end(); it++) {
        printf("    ZONE #%d rcnt=%02lu name=%s%s\n", (*it)->id, (*it)->refcnt-1, (*it)->name, (*it)->is_local ? " (local)" : "");
    }
}

};};
