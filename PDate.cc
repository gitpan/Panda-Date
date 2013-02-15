#include "PDate.h"

PDate::PDate (time_t from) : _error(E_OK)  { epoch(from); }
PDate::PDate (const char* str, size_t len) { setFrom(str, len); }
PDate::PDate (PDate* from)                 { setFrom(from); }
PDate::PDate (SV* arg)                     { setFrom(arg); }

void PDate::eCheck () { if (!_hasEpoch && _hasData) eSync(); }
void PDate::eSync  () { // this function is heavy
    _hasEpoch = true;
    _hasFullData = true;
    _data.tm_isdst = -1;
    _epoch = mktime(&_data);
}

void PDate::dNorm () { dNorm(0); }
void PDate::dNorm (uint8_t flags) {
    struct tm old;

    if (flags & NORM_YDAY) {
        _data.tm_mon = 0;
        _data.tm_mday = 0;
    } else {
        _data.tm_yday = -1;
    }
    
    _data.tm_wday = 7; // wday is only set when its out of range, yday is always set
    
    if (flags & (NORM_RCHECK|NORM_MBA)) old = _data;
    
    normalize(&_data);
    _hasFullData = false;
    
    if (flags & NORM_RCHECK) {
        if (old.tm_sec > 60 || old.tm_min >= 60 || old.tm_hour >= 24) {
            error(E_RANGE);
            return;
        }
       
        if (flags & NORM_YDAY) {
            if (old.tm_year != _data.tm_year) {
                error(E_RANGE);
                return;
            }
        } else {
            if (old.tm_mday != _data.tm_mday || old.tm_mon != _data.tm_mon || old.tm_year != _data.tm_year) {
                error(E_RANGE);
                return;
            }
        }
    }
    
    // dNorm should be called with NORM_MBA flag ONLY WHEN month or year changed ONLY. ONLY MONTH OR YEAR, nothing else.
    // if you need add more properties and still use NORM_MBA you should add months and years and call dNorm(NORM_MBA);
    // and then add rest, then call dNorm()
    if ((flags & NORM_MBA) && old.tm_mday > _data.tm_mday) {
        // December cannot cause overflow because it has 31 - max possible days.
        // Therefore we can safely get previous month by 'mon--'. Also set the last day of month.
        // Should tune yday,wday either.
        _data.tm_mon--;
        _data.tm_yday -= _data.tm_mday;
        _data.tm_wday -= _data.tm_mday;
        if (_data.tm_wday < 0) _data.tm_wday += 7;
        _data.tm_mday = days_in_month(_data.tm_year+1900, _data.tm_mon+1);
    }
}

void PDate::dCheck () { if (!_hasData && _hasEpoch) dSync(); }

void PDate::dCheckFull () {
    if (_hasData && _hasFullData) return;
    if (_hasEpoch) dSync(); // use 'from epoch sync' if possible (lite)
    else if (_hasData) eSync(); // otherwise use 'from data sync' (heavy)
}

void PDate::dSync  () { // this function is relatively lite
    _hasData = true;
    _hasFullData = true;
    localtime_r(&_epoch, &this->_data);
}

struct tm * PDate::data        ()            { dCheck(); return &_data; }
bool        PDate::hasEpoch    ()            { return _hasEpoch; }
bool        PDate::hasData     ()            { return _hasData; }
bool        PDate::hasFullData ()            { return _hasFullData; }
uint8_t     PDate::error       ()            { return _error; }
void        PDate::error       (uint8_t val) { _error = val; epoch(0); }

time_t PDate::epoch ()           { eCheck(); return _epoch; }
void   PDate::epoch (time_t val) { _epoch = val; _hasEpoch = true; _hasData = false; _hasFullData = false; }

int32_t PDate::year  ()            { dCheck(); return _data.tm_year + 1900; }
void    PDate::year  (int32_t val) { dCheck(); _data.tm_year = val - 1900; _hasEpoch = false; dNorm(monthBorderAdjust ? NORM_MBA : 0); }
int32_t PDate::_year ()            { return year()-1900; }
void    PDate::_year (int32_t val) { year(val+1900); }
int8_t  PDate::yr    ()            { dCheck(); return _data.tm_year % 100; }
void    PDate::yr    (int8_t val)  { year( year() - yr() + val ); }

uint8_t PDate::month ()             { dCheck(); return _data.tm_mon + 1; }
void    PDate::month (int32_t val)  { dCheck(); _data.tm_mon = val - 1; _hasEpoch = false; dNorm(monthBorderAdjust ? NORM_MBA : 0); }
uint8_t PDate::_month ()            { return month() - 1; }
void    PDate::_month (int32_t val) { month(val+1); }

uint8_t PDate::day ()            { dCheck(); return _data.tm_mday; }
void    PDate::day (int32_t val) { dCheck(); _data.tm_mday = val; _hasEpoch = false; dNorm(); }

uint8_t PDate::hour ()            { dCheck(); return _data.tm_hour; }
void    PDate::hour (int32_t val) { dCheck(); _data.tm_hour = val; _hasEpoch = false; dNorm(); }

uint8_t PDate::min ()            { dCheck(); return _data.tm_min; }
void    PDate::min (int32_t val) { dCheck(); _data.tm_min = val; _hasEpoch = false; dNorm(); }

uint8_t PDate::sec ()            { dCheck(); return _data.tm_sec; }
void    PDate::sec (int32_t val) { dCheck(); _data.tm_sec = val; _hasEpoch = false; dNorm(); }

uint8_t PDate::wday ()              { dCheck(); return _data.tm_wday + 1; }
void    PDate::wday (uint8_t val)   { dCheck(); _data.tm_mday += val - (_data.tm_wday + 1); _hasEpoch = false; dNorm(); }
uint8_t PDate::_wday ()             { return wday() - 1; }
void    PDate::_wday (uint8_t val)  { wday(val+1); }
uint8_t PDate::ewday ()             { dCheck(); return _data.tm_wday == 0 ? 7 : _data.tm_wday; }
void    PDate::ewday (uint8_t val)  { _data.tm_mday += val - ewday(); _hasEpoch = false; dNorm(); }

uint16_t PDate::yday ()              { dCheck(); return _data.tm_yday + 1; }
void     PDate::yday (uint32_t val)  { dCheck(); _data.tm_yday = val - 1; _hasEpoch = false; dNorm(NORM_YDAY); }
uint16_t PDate::_yday ()             { return yday() - 1; }
void     PDate::_yday (uint32_t val) { yday(val+1); }

bool        PDate::isdst    () { dCheckFull(); return _data.tm_isdst == 0 ? false : true; }
int32_t     PDate::tzoffset () { dCheckFull(); return _data.tm_gmtoff; }
const char* PDate::tz       () { return tzname[0]; }
const char* PDate::tzdst    () { dCheckFull(); return _data.tm_zone; }

uint8_t PDate::daysInMonth () {
    dCheck();
    return days_in_month(_data.tm_year+1900, _data.tm_mon+1);
}

void PDate::setFrom (SV* arg) {
    _error = E_OK; // reset possible error;
    if (SvOK(arg)) {
        if (SvROK(arg)) {
            if (sv_isobject(arg) && sv_isa(arg, PDATE_CLASS)) setFrom((PDate *) SvIV(SvRV(arg)));
            else {
                SV* rarg = SvRV(arg);
                if (SvTYPE(rarg) == SVt_PVHV) setFrom((HV*) rarg, false);
                else if (SvTYPE(rarg) == SVt_PVAV) setFrom((AV*) rarg);
                else croak("Panda::Date - cannot create object - unknown argument passed");
            }
        }
        else if (looks_like_number(arg)) {
            epoch(SvIV(arg));
        }
        else {
            STRLEN len;
            const char* str = SvPV(arg, len);
            setFrom(str, len);
        }
    }
    else epoch(0);
}

void PDate::setFrom (AV* from) {
    int32_t year = 2000;
    int32_t month = 1;
    int32_t day = 1;
    int32_t hour = 0;
    int32_t min = 0;
    int32_t sec = 0;
    I32 len = av_len(from)+1;
    SV** ref;
    if (len > 0) { ref = av_fetch(from, 0, 0); if (ref != NULL) year  = SvIV(*ref); }
    if (len > 1) { ref = av_fetch(from, 1, 0); if (ref != NULL) month = SvIV(*ref); }
    if (len > 2) { ref = av_fetch(from, 2, 0); if (ref != NULL) day   = SvIV(*ref); }
    if (len > 3) { ref = av_fetch(from, 3, 0); if (ref != NULL) hour  = SvIV(*ref); }
    if (len > 4) { ref = av_fetch(from, 4, 0); if (ref != NULL) min   = SvIV(*ref); }
    if (len > 5) { ref = av_fetch(from, 5, 0); if (ref != NULL) sec   = SvIV(*ref); }
    setFrom(year, month, day, hour, min, sec);
}

void PDate::setFrom (HV* from, bool cloning) {
    _error = E_OK;
    if (cloning) dCheck();
    SV** ref;
    
    ref = hv_fetch(from, "year", 4, 0);
    if (ref != NULL) _data.tm_year = SvIV(*ref) - 1900;
    else if (!cloning) _data.tm_year = 100;
    
    ref = hv_fetch(from, "month", 5, 0);
    if (ref != NULL) _data.tm_mon = SvIV(*ref) - 1;
    else if (!cloning) _data.tm_mon = 0;

    ref = hv_fetch(from, "day", 3, 0);
    if (ref != NULL) _data.tm_mday = SvIV(*ref);
    else if (!cloning) _data.tm_mday = 1;

    ref = hv_fetch(from, "hour", 4, 0);
    if (ref != NULL) _data.tm_hour = SvIV(*ref);
    else if (!cloning) _data.tm_hour = 0;

    ref = hv_fetch(from, "min", 3, 0);
    if (ref != NULL) _data.tm_min = SvIV(*ref);
    else if (!cloning) _data.tm_min = 0;

    ref = hv_fetch(from, "sec", 3, 0);
    if (ref != NULL) _data.tm_sec = SvIV(*ref);
    else if (!cloning) _data.tm_sec = 0;
    
    if (cloning) {
        ref = hv_fetch(from, "_year", 5, 0);
        if (ref != NULL) _data.tm_year = SvIV(*ref);
        
        ref = hv_fetch(from, "_month", 6, 0);
        if (ref != NULL) _data.tm_mon = SvIV(*ref);
    }
    
    dNorm(rangeCheck ? NORM_RCHECK : 0);
    _hasData = true;
    _hasFullData = false;
    _hasEpoch = false;
}

void PDate::setFrom (int32_t year, int32_t month, int32_t day, int32_t hour, int32_t min, int32_t sec) {
    _error        = E_OK;
    _data.tm_year = year - 1900;
    _data.tm_mon  = month - 1;
    _data.tm_mday = day;
    _data.tm_hour = hour;
    _data.tm_min  = min;
    _data.tm_sec  = sec;
    dNorm(rangeCheck ? NORM_RCHECK : 0);
    _hasData = true;
    _hasFullData = false;
    _hasEpoch = false;
}

void PDate::setFrom (const char* str, size_t len) {
    _error = parse_iso(str, len, _data);
    
    if (_error != E_OK) {
        error(_error);
        return;
    }
    
    dNorm(rangeCheck ? NORM_RCHECK : 0);
    _hasData = true;
    _hasFullData = false;
    _hasEpoch = false;
}

void PDate::setFrom (PDate* from) {
    _error       = from->error();
    _hasEpoch    = from->hasEpoch();
    _hasData     = from->hasData();
    _hasFullData = from->hasFullData();
    if (_hasEpoch) _epoch = from->epoch();
    if (_hasData) _data = *(from->data());
}

const char* PDate::toString () {
    if (_error > E_OK) return NULL;
    return strfmt == NULL ? iso() : strFtime(strfmt, NULL, 0);
}

const char* PDate::iso () {
    TOSTR_START(50);
    TOSTR_YEAR; TOSTR_DEL('-'); TOSTR_MONTH; TOSTR_DEL('-'); TOSTR_DAY; TOSTR_DEL(' ');
    TOSTR_HOUR; TOSTR_DEL(':'); TOSTR_MIN; TOSTR_DEL(':'); TOSTR_SEC;
    TOSTR_END;
}

const char* PDate::mysql () {
    TOSTR_START(45);
    TOSTR_YEAR; TOSTR_MONTH; TOSTR_DAY; TOSTR_HOUR; TOSTR_MIN; TOSTR_SEC;
    TOSTR_END;
}

const char* PDate::hms () {
    TOSTR_START(8); TOSTR_HOUR; TOSTR_DEL(':'); TOSTR_MIN; TOSTR_DEL(':'); TOSTR_SEC; TOSTR_END;
}

const char* PDate::ymd () {
    TOSTR_START(41); TOSTR_YEAR; TOSTR_DEL('/'); TOSTR_MONTH; TOSTR_DEL('/'); TOSTR_DAY; TOSTR_END;
}

const char* PDate::mdy () {
    TOSTR_START(41); TOSTR_MONTH; TOSTR_DEL('/'); TOSTR_DAY; TOSTR_DEL('/'); TOSTR_YEAR; TOSTR_END;
}

const char* PDate::dmy () {
    TOSTR_START(41); TOSTR_DAY; TOSTR_DEL('/'); TOSTR_MONTH; TOSTR_DEL('/'); TOSTR_YEAR; TOSTR_END;
}

const char* PDate::meridiam () {
    TOSTR_START(8);
    uint8_t hour = _data.tm_hour % 12;
    if (hour == 0) hour = 12;
    TOSTR_VAL2(hour); TOSTR_DEL(':'); TOSTR_MIN; TOSTR_DEL(' '); TOSTR_AMPM;
    TOSTR_END;
}

char* PDate::strFtime (const char* format, char* buf, size_t maxsize) {
    dCheckFull();
    static char defbuf[1000];
    if (buf == NULL) {
        buf = defbuf;
        maxsize = 1000;
    }
    size_t reslen = strftime(buf, maxsize, format, &_data);
    return reslen > 0 ? buf : NULL;
}

const char* PDate::ampm () {
    dCheck();
    return _data.tm_hour < 12 ? "AM" : "PM";
}

PDate* PDate::clone      () { return new PDate(this); }
PDate* PDate::truncate   () { return clone()->truncateME(); }
PDate* PDate::monthBegin () { return clone()->monthBeginME(); }
PDate* PDate::monthEnd   () { return clone()->monthEndME(); }

PDate* PDate::monthBeginME () {
    dCheck();
    uint8_t delta = _data.tm_mday - 1;
    WDAY_CHANGE(_data.tm_wday, -delta);
    _data.tm_yday -= delta;
    _data.tm_mday = 1;
    _hasEpoch     = false;
    _hasFullData  = false;
    return this;
}

PDate* PDate::monthEndME () {
    dCheck();
    uint8_t newval = daysInMonth();
    uint8_t delta = newval - _data.tm_mday;
    WDAY_CHANGE(_data.tm_wday, delta);
    _data.tm_yday += delta;
    _data.tm_mday = newval;
    _hasEpoch     = false;
    _hasFullData  = false;
    return this;
}

PDate* PDate::truncateME () { // low-level sec-min-hour set -> great perfomance
    dCheck();
    _data.tm_sec  = 0;
    _data.tm_min  = 0;
    _data.tm_hour = 0;
    _hasEpoch     = false;
    _hasFullData  = false;
    return this;
}

void PDate::_dbg () {
    warn("hasE=%d e=%lli hasD=%d hasFD=%d y=%d m=%d d=%d, wd=%d yd=%d dst=%d",
         _hasEpoch ? 1 : 0, _epoch, _hasData ? 1 : 0, _hasFullData ? 1 : 0, _data.tm_year, _data.tm_mon,
         _data.tm_mday, _data.tm_wday, _data.tm_yday, _data.tm_isdst);
}

const char* PDate::errstr () {
    switch (_error) {
        case E_OK:
            return NULL;
        case E_UNPARSABLE:
            return "can't parse date string";
        case E_RANGE:
            return "input date is out of range";
        default:
            return "unknown error";
    }
}

int PDate::compare (PDate* operand) {
    if (_hasEpoch && operand->hasEpoch()) return num_compare(_epoch, operand->epoch());
    else return tm_compare(*(data()), *(operand->data()));
}

PDate* PDate::_addsubME (PDateRel* operand, bool subtract) {
    dCheck();
    int sign = subtract ? -1 : 1;
    // process year/month separately from DHMS to allow monthBorderAdjust to work correctly
    if (operand->hasMPart()) {
        _data.tm_mon  += sign*operand->month();
        _data.tm_year += sign*operand->year();
        dNorm(monthBorderAdjust ? NORM_MBA : 0);
    }
    
    if (operand->hasSPart()) {
        _data.tm_sec  += sign*operand->sec();
        _data.tm_min  += sign*operand->min();
        _data.tm_hour += sign*operand->hour();
        _data.tm_mday += sign*operand->day();
        dNorm();
    }
    
    _hasEpoch = false;
    return this;
}

PDate* PDate::add        (PDateRel* operand) { return clone()->addME(operand); }
PDate* PDate::addME      (PDateRel* operand) { return _addsubME(operand, false); }
PDate* PDate::subtract   (PDateRel* operand) { return clone()->subtractME(operand); }
PDate* PDate::subtractME (PDateRel* operand) { return _addsubME(operand, true); }

PDate::~PDate () {}

/////////   STATIC   ///////////////////////////////
bool        PDate::monthBorderAdjust = false;
bool        PDate::rangeCheck        = false;
SV*         PDate::strfmtSV          = NULL;
const char* PDate::strfmt            = NULL;

SV* PDate::stringFormatSV () { return strfmtSV; }

void PDate::stringFormatSV (SV* format) {
    if (strfmtSV != NULL) {
        SvREFCNT_dec(strfmtSV);
        strfmtSV = NULL;
        strfmt = NULL;
    }
    
    if (SvOK(format) && SvTRUE(format)) {
        SvREFCNT_inc(format);
        strfmtSV = format;
        strfmt = SvPV_nolen(format);
    }
}

PDate* PDate::now   () { return new PDate(time(NULL)); }
PDate* PDate::today () { return now()->truncateME(); }
