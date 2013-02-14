#include "PDateInt.h"

PDateInt::PDateInt ()                         : _from((time_t) 0), _till((time_t) 0) {}
PDateInt::PDateInt (PDate* from, PDate* till) : _from(from), _till(till)             {}
PDateInt::PDateInt (SV* from, SV* till)       : _from(from), _till(till)             {}
PDateInt::PDateInt (SV* arg)                  : _from((time_t) 0), _till((time_t) 0) { setFrom(arg); }

void PDateInt::setFrom (SV* arg) {
    if (SvOK(arg) && SvROK(arg)) {
        SV* argval = SvRV(arg);
        if (SvTYPE(argval) == SVt_PVAV) {
            AV* arr = (AV*) argval;
            SV** elemref1 = av_fetch(arr, 0, 0);
            SV** elemref2 = av_fetch(arr, 1, 0);
            if (elemref1 != NULL && elemref2 != NULL) {
                _from.setFrom(*elemref1);
                _till.setFrom(*elemref2);
                return;
            }
        }
    }
    else if (SvPOK(arg)) {
        STRLEN len;
        const char* str = SvPV(arg, len);
        if (setFrom(str, len)) return;
    }
    
    croak("Panda::Date: cannot set Panda::Date::Int object - wrong argument");
}

void PDateInt::setFrom (SV* fromSV, SV* tillSV) {
    _from.setFrom(fromSV);
    _till.setFrom(tillSV);
}

bool PDateInt::setFrom (const char* str, size_t len) {
    char* ptr = (char*) str;
    char* from_str = strsep(&ptr, "~");
    if (ptr == NULL || ptr >= str + len - 1) return false;
    _from.setFrom(from_str, strlen(from_str));
    _till.setFrom(ptr+1, strlen(ptr)-1);
    return true;
}

const char* PDateInt::toString () {
    if (hasError()) return NULL;
    static char str[100];
    char* ptr = str;
    const char* src = _from.toString();
    while (*src) *(ptr++) = *(src++);
    *(ptr++) = ' '; *(ptr++) = '~'; *(ptr++) = ' ';
    src = _till.toString();
    while (*src) *(ptr++) = *(src++);
    *(ptr++) = 0;
    return str;
}

bool PDateInt::hasError () { return _from.error() != E_OK || _till.error() != E_OK; }

PDate* PDateInt::from ()        { return &_from; }
void   PDateInt::from (SV* arg) { _from.setFrom(arg); }
PDate* PDateInt::till ()        { return &_till; }
void   PDateInt::till (SV* arg) { _till.setFrom(arg); }

int64_t PDateInt::hmsDiff () {
    return (_till.hour() - _from.hour())*3600 + (_till.min() - _from.min())*60 + _till.sec() - _from.sec();
}

int64_t PDateInt::duration () { return hasError() ? 0 : (_till.epoch() - _from.epoch()); }
int64_t PDateInt::sec      () { return duration(); }
int64_t PDateInt::imin     () { return duration()/60; }
double  PDateInt::min      () { return (double) duration()/60; }
int64_t PDateInt::ihour    () { return duration()/3600; }
double  PDateInt::hour     () { return (double) duration()/3600; }

int64_t PDateInt::iday     () { return (int64_t) day(); }
double  PDateInt::day      () { return christ_days(_till.year()) + _till.yday() - christ_days(_from.year()) - _from.yday() + (double) hmsDiff() / 86400; }

int64_t PDateInt::imonth   () { return (int64_t) month(); }
double  PDateInt::month    () {
    return (_till.year() - _from.year())*12 + _till.month() - _from.month() + 
           (double) (_till.day() - _from.day() + (double) hmsDiff() / 86400) / _from.daysInMonth();
}

int64_t PDateInt::iyear    () { return (int64_t) year(); }
double  PDateInt::year     () { return month() / 12; }

PDateRel* PDateInt::relative () {
    return new PDateRel(*(_from.data()), *(_till.data()));
}

PDateInt* PDateInt::clone () { return new PDateInt(&_from, &_till); }

PDateInt* PDateInt::add   (PDateRel* operand) { return clone()->addME(operand); }
PDateInt* PDateInt::addME (PDateRel* operand) {
    _from.addME(operand);
    _till.addME(operand);
    return this;
}

PDateInt* PDateInt::subtract   (PDateRel* operand) { return clone()->subtractME(operand); }
PDateInt* PDateInt::subtractME (PDateRel* operand) {
    _from.subtractME(operand);
    _till.subtractME(operand);
    return this;
}

PDateInt* PDateInt::negative   () { return new PDateInt(&_till, &_from); }
PDateInt* PDateInt::negativeME () {
    static PDate tmp((time_t) 0);
    tmp.setFrom(&_from);
    _from.setFrom(&_till);
    _till.setFrom(&tmp);
    return this;
}

int  PDateInt::compare (PDateInt* operand) { return num_compare(duration(), operand->duration()); }
bool PDateInt::equals  (PDateInt* operand) {
    return _from.compare(operand->from()) == 0 && _till.compare(operand->till()) == 0;
}

PDateInt::~PDateInt () {};
