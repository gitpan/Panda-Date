#include "PDateRel.h"

PDateRel::PDateRel () : _sec(0), _min(0), _hour(0), _day(0), _month(0), _year(0) {};

PDateRel::PDateRel (PDateRel* from) {
    _sec   = from->sec();
    _min   = from->min();
    _hour  = from->hour();
    _day   = from->day();
    _month = from->month();
    _year  = from->year();
}

PDateRel::PDateRel (SV* arg)                          { setFrom(arg); }
PDateRel::PDateRel (struct tm &from, struct tm &till) { setFrom(from, till); }
PDateRel::PDateRel (SV* fromSV, SV* tillSV)           { setFrom(fromSV, tillSV); }
PDateRel::PDateRel (const char* str, size_t len)      { setFrom(str, len); }

void PDateRel::setFrom (SV* fromSV, SV* tillSV) {
    static PDate from((time_t) 0);
    static PDate till((time_t) 0);
    from.setFrom(fromSV);
    till.setFrom(tillSV);
    setFrom(*(from.data()), *(till.data()));
}

void PDateRel::setFrom (struct tm &from, struct tm &till) {
    _sec = 0, _min = 0, _hour = 0, _day = 0, _month = 0, _year = 0;
    bool reverse = false;
    if (tm_compare(from, till) > 0) {
        reverse = true;
        struct tm tmp = from;
        from = till;
        till = tmp;
    }
    
    _sec = till.tm_sec - from.tm_sec;
    if (_sec < 0) { _sec += 60; _min--; }
    
    _min += till.tm_min - from.tm_min;
    if (_min < 0) { _min += 60; _hour--; }
    
    _hour += till.tm_hour - from.tm_hour;
    if (_hour < 0) { _hour += 24; _day--; }
    
    _day += till.tm_mday - from.tm_mday;
    if (_day < 0) {
        int tmpy = till.tm_year;
        int tmpm = till.tm_mon-1;
        if (tmpm < 0) { tmpm += 12; tmpy--; }
        int days = days_in_month(tmpy+1900, tmpm+1);
        _day += days;
        _month--;
    }
    
    _month += till.tm_mon - from.tm_mon;
    if (_month < 0) { _month += 12; _year --; }
    
    _year += till.tm_year - from.tm_year;
    
    if (reverse) negativeME();
}

void PDateRel::setFrom (SV* arg) {
    _sec = 0; _min = 0; _hour = 0; _day = 0; _month = 0; _year = 0;
    if (!SvOK(arg)) return;
    if (SvROK(arg)) {
        if (sv_isobject(arg) && sv_isa(arg, PDATE_REL_CLASS)) setFrom((PDateRel *) SvIV(SvRV(arg)));
        else {
            SV* rarg = SvRV(arg);
            if (SvTYPE(rarg) == SVt_PVHV) setFrom((HV*) rarg);
            else if (SvTYPE(rarg) == SVt_PVAV) setFrom((AV*) rarg);
            else croak("Panda::Date::Rel - cannot create object - unknown argument passed");
        }
    }
    else if (looks_like_number(arg)) {
        _sec = SvIV(arg);
    }
    else {
        STRLEN len;
        const char* str = SvPV(arg, len);
        setFrom(str, len);
    }
}

void PDateRel::setFrom (PDateRel* from) {
    _sec   = from->sec();
    _min   = from->min();
    _hour  = from->hour();
    _day   = from->day();
    _month = from->month();
    _year  = from->year();
}

int64_t PDateRel::sec   ()            { return _sec; }
void    PDateRel::sec   (int64_t val) { _sec = val; }
int64_t PDateRel::min   ()            { return _min; }
void    PDateRel::min   (int64_t val) { _min = val; }
int64_t PDateRel::hour  ()            { return _hour; }
void    PDateRel::hour  (int64_t val) { _hour = val; }
int64_t PDateRel::day   ()            { return _day; }
void    PDateRel::day   (int64_t val) { _day = val; }
int64_t PDateRel::month ()            { return _month; }
void    PDateRel::month (int64_t val) { _month = val; }
int64_t PDateRel::year  ()            { return _year; }
void    PDateRel::year  (int64_t val) { _year = val; }

void PDateRel::setFrom (HV* from) {
    SV** ref;
    ref = hv_fetch(from, "year", 4, 0);
    if (ref != NULL) _year = SvIV(*ref);
    ref = hv_fetch(from, "month", 5, 0);
    if (ref != NULL) _month = SvIV(*ref);
    ref = hv_fetch(from, "day", 3, 0);
    if (ref != NULL) _day = SvIV(*ref);
    ref = hv_fetch(from, "hour", 4, 0);
    if (ref != NULL) _hour = SvIV(*ref);
    ref = hv_fetch(from, "min", 3, 0);
    if (ref != NULL) _min = SvIV(*ref);
    ref = hv_fetch(from, "sec", 3, 0);
    if (ref != NULL) _sec = SvIV(*ref);
}

void PDateRel::setFrom (AV* from) {
    I32 len = av_len(from)+1;
    SV** ref;
    if (len > 0) { ref = av_fetch(from, 0, 0); if (ref != NULL) _year  = SvIV(*ref); }
    if (len > 1) { ref = av_fetch(from, 1, 0); if (ref != NULL) _month = SvIV(*ref); }
    if (len > 2) { ref = av_fetch(from, 2, 0); if (ref != NULL) _day   = SvIV(*ref); }
    if (len > 3) { ref = av_fetch(from, 3, 0); if (ref != NULL) _hour  = SvIV(*ref); }
    if (len > 4) { ref = av_fetch(from, 4, 0); if (ref != NULL) _min   = SvIV(*ref); }
    if (len > 5) { ref = av_fetch(from, 5, 0); if (ref != NULL) _sec   = SvIV(*ref); }
}

void PDateRel::setFrom (const char* str, size_t len) {
    struct tm data;
    uint8_t error = parse_relative(str, len, data);
    if (error != E_OK) return;
    _year  = data.tm_year;
    _month = data.tm_mon;
    _day   = data.tm_mday;
    _hour  = data.tm_hour;
    _min   = data.tm_min;
    _sec   = data.tm_sec;
}

const char* PDateRel::toString () {
    RELSTR_START(65);
    if (_year  != 0) { RELSTR_VAL(_year, 'Y') }
    if (_month != 0) { RELSTR_VAL(_month, 'M') }
    if (_day   != 0) { RELSTR_VAL(_day, 'D') }
    if (_hour  != 0) { RELSTR_VAL(_hour, 'h') }
    if (_min   != 0) { RELSTR_VAL(_min, 'm') }
    if (_sec   != 0) { RELSTR_VAL(_sec, 's') }
    RELSTR_END;
}

bool PDateRel::empty () { return _sec == 0 && _min == 0 && _hour == 0 && _day == 0 && _month == 0 && _year == 0; }
bool PDateRel::hasMPart () { return _year != 0 || _month != 0; }
bool PDateRel::hasSPart () { return _sec != 0 || _min != 0 || _hour != 0 || _day != 0; }

int64_t PDateRel::toSec   () { return _sec + _min*60 + _hour*3600 + _day * 86400 + (_month + 12*_year) * 2629744; }
double  PDateRel::toMin   () { return (double) toSec() / 60; }
double  PDateRel::toHour  () { return (double) toSec() / 3600; }
double  PDateRel::toDay   () { return (double) toSec() / 86400; }
double  PDateRel::toMonth () { return (double) toSec() / 2629744; }
double  PDateRel::toYear  () { return toMonth() / 12; }

PDateRel* PDateRel::clone () { return new PDateRel(this); }

PDateRel* PDateRel::multiply   (double koef) { return clone()->multiplyME(koef); }
PDateRel* PDateRel::multiplyME (double koef) {
    if (fabs(koef) < 1 && koef != 0) return divideME(1/koef);
    _sec   *= koef;
    _min   *= koef;
    _hour  *= koef;
    _day   *= koef;
    _month *= koef;
    _year  *= koef;
    return this;
}

PDateRel* PDateRel::divide   (double koef) { return clone()->divideME(koef); }
PDateRel* PDateRel::divideME (double koef) {
    if (fabs(koef) <= 1) return multiplyME(1/koef);
    double td;
    int64_t tmp;
    
    tmp = _year;
    _year /= koef;
    td = (tmp - _year*koef)*12;
    tmp = td;
    _month += tmp;
    td = (td - tmp)*((double)2629744/86400);
    tmp = td;
    _day += tmp;
    td = (td - tmp)*24;
    tmp = td;
    _hour += tmp;
    td = (td - tmp)*60;
    tmp = td;
    _min += tmp;
    td = (td - tmp)*60;
    _sec += td;

    tmp = _month;
    _month /= koef;
    td = (tmp - _month*koef)*((double)2629744/86400);
    tmp = td;
    _day += tmp;
    td = (td - tmp)*24;
    tmp = td;
    _hour += tmp;
    td = (td - tmp)*60;
    tmp = td;
    _min += tmp;
    td = (td - tmp)*60;
    _sec += td;
    
    tmp = _day;
    _day /= koef;
    td = (tmp - _day*koef)*24;
    tmp = td;
    _hour += tmp;
    td = (td - tmp)*60;
    tmp = td;
    _min += tmp;
    td = (td - tmp)*60;
    _sec += td;
    
    tmp = _hour;
    _hour /= koef;
    td = (tmp - _hour*koef)*60;
    tmp = td;
    _min += tmp;
    td = (td - tmp)*60;
    _sec += td;
    
    tmp = _min;
    _min /= koef;
    _sec += (tmp - _min*koef)*60;
    
    _sec /= koef;
    
    return this;
}

PDateRel* PDateRel::add   (PDateRel* operand) { return clone()->addME(operand); }
PDateRel* PDateRel::addME (PDateRel* operand) {
    _sec   += operand->sec();
    _min   += operand->min();
    _hour  += operand->hour();
    _day   += operand->day();
    _month += operand->month();
    _year  += operand->year();
    return this;
}

PDateRel* PDateRel::subtract   (PDateRel* operand) { return clone()->subtractME(operand); }
PDateRel* PDateRel::subtractME (PDateRel* operand) {
    _sec   -= operand->sec();
    _min   -= operand->min();
    _hour  -= operand->hour();
    _day   -= operand->day();
    _month -= operand->month();
    _year  -= operand->year();
    return this;
}

PDateRel* PDateRel::negative   () { return clone()->negativeME(); }
PDateRel* PDateRel::negativeME () {
    _sec   = -_sec;
    _min   = -_min;
    _hour  = -_hour;
    _day   = -_day;
    _month = -_month;
    _year  = -_year;
    return this;
}

int PDateRel::compare (PDateRel* operand) {
    int64_t valME = toSec();
    int64_t valO  = operand->toSec();
    return valME > valO ? 1 : (valME == valO ? 0 : -1);
}

bool PDateRel::equals (PDateRel* operand) {
    return _sec == operand->sec() && _min == operand->min() && _hour == operand->hour() &&
           _day == operand->day() && _month == operand->month() && _year == operand->year();
}

PDateRel::~PDateRel () {};
