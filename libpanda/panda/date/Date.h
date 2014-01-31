#ifndef pdate_Date_h_included
#define pdate_Date_h_included

#include "inc.h"
#include "parse.h"

namespace panda { namespace date {

using panda::time::tz;
using panda::time::dt;
using panda::time::days_in_month;
using panda::time::tzget;
using panda::time::tzlocal;
    
class DateRel;

class Date {

private:
    static const int MAX_FMT = 255;
    static char      _strfmt[MAX_FMT+1];
    static bool      _rangeCheck;

    tz*     _zone;
    ptime_t _epoch;
    dt      _date;
    bool    _hasEpoch;
    bool    _hasDate;
    bool    _normalized;
    uint8_t _error;
    
    void eSync ();
    void dSync ();
    
    void eCheck ();
    void dCheck ();
    
    int validateRange();

    void _zone_set (tz* zone);

public: 
    static Date* now   ();
    static Date* today ();
    
    static void stringFormat (const char*);
    static const char* stringFormat ();
    static void rangeCheck (bool);
    static bool rangeCheck ();

    Date (const Date& source);
    Date (ptime_t epoch = (ptime_t) ::time(NULL), tz* zone = NULL);
    Date (const char* str, size_t len = 0, tz* zone = NULL);
    Date (int32_t, ptime_t, ptime_t, ptime_t, ptime_t, ptime_t, int isdst = -1, tz* zone = NULL);
    Date (const Date* source, tz* zone = NULL);
    ~Date ();
    
    Date& operator= (const Date&);

    void set (ptime_t, tz* = NULL);
    int  set (const char* str, size_t len = 0, tz* zone = NULL);
    int  set (int32_t, ptime_t, ptime_t, ptime_t, ptime_t, ptime_t, int isdst = -1, tz* zone = NULL);
    void set (const Date*, tz* zone = NULL);
    
    int change (int32_t year, ptime_t mon=-1, ptime_t day=-1, ptime_t hour=-1, ptime_t min=-1, ptime_t sec=-1, int isdst=-1, tz* zone=NULL);

    ptime_t epoch ();
    void    epoch (ptime_t);
    
    const dt* date       ();
    bool      hasEpoch   () const;
    bool      hasDate    () const;
    bool      normalized () const;
    uint8_t   error      () const;
    void      error      (uint8_t);
    tz*       timezone   () const;
    void      timezone   (tz*);
    void      toTimezone (tz*);
    
    int32_t year  ();
    void    year  (int32_t);
    int32_t _year ();
    void    _year (int32_t);
    int8_t  yr    ();
    void    yr    (int);
    
    uint8_t month  ();
    void    month  (ptime_t);
    uint8_t _month ();
    void    _month (ptime_t);
    
    uint8_t mday ();
    void    mday (ptime_t);
    uint8_t day  ();
    void    day  (ptime_t);
    
    uint8_t hour ();
    void    hour (ptime_t);
    
    uint8_t min ();
    void    min (ptime_t);
    
    uint8_t sec ();
    void    sec (ptime_t);
    
    uint8_t wday ();
    void    wday (ptime_t);
    uint8_t _wday ();
    void    _wday (ptime_t);
    uint8_t ewday ();
    void    ewday (ptime_t);
    
    uint16_t yday ();
    void     yday (ptime_t);
    uint16_t _yday ();
    void     _yday (ptime_t);

    bool        isdst  ();
    int32_t     gmtoff ();
    const char* tzabbr ();
    
    int   daysInMonth ();
    Date* clone       (tz* zone = NULL) const;
    Date* clone       (int32_t year, ptime_t mon=-1, ptime_t day=-1, ptime_t hour=-1, ptime_t min=-1, ptime_t sec=-1, int isdst=-1, tz* zone=NULL) const;
    Date* monthBegin  ();
    Date* monthEnd    ();
    int   compare     (Date*);
    bool  lt          (Date*);
    bool  lte         (Date*);
    bool  gt          (Date*);
    bool  gte         (Date*);
    bool  equals      (Date*);
    Date* add         (const DateRel*);
    Date* subtract    (const DateRel*);
    
    Date* truncate ();

    Date* truncateNew   () const;
    Date* monthBeginNew () const;
    Date* monthEndNew   () const;
    Date* addNew        (const DateRel*) const;
    Date* subtractNew   (const DateRel*) const;
    
    char*       strftime (const char*, char*, size_t);
    const char* toString ();
    const char* errstr   () const;
   
    const char* iso      ();
    const char* mysql    ();
    const char* hms      ();
    const char* ymd      ();
    const char* mdy      ();
    const char* dmy      ();
    const char* meridiam ();
    const char* ampm     ();
};

inline Date::Date (const Date& source) : _zone(NULL) {
    set(&source);
}

inline Date::Date (ptime_t val, tz* zone) : _zone(NULL), _error(E_OK) {
    set(val, zone);
}

inline Date::Date (const char* str, size_t len, tz* zone) : _zone(NULL) {
    set(str, len, zone);
}

inline Date::Date (int32_t year, ptime_t mon, ptime_t day, ptime_t hour, ptime_t min, ptime_t sec, int isdst, tz* zone) : _zone(NULL) {
    set(year, mon, day, hour, min, sec, isdst, zone);
}

inline Date::Date (const Date* source, tz* zone) : _zone(NULL) {
    set(source, zone);
}

inline void Date::set (ptime_t val, tz* zone) {
    _zone_set(zone);
    epoch(val);
}

inline int Date::set (const char* str, size_t len, tz* zone) {
    _zone_set(zone);
    _error      = parse_iso(str, len, &_date);
    _hasEpoch   = false;
    _hasDate    = true;
    _normalized = false;
    if (_rangeCheck && !_error) validateRange();
    return _error;
}

inline int Date::set (int32_t year, ptime_t month, ptime_t day, ptime_t hour, ptime_t min, ptime_t sec, int isdst, tz* zone) {
    _zone_set(zone);
    _error      = E_OK;
    _date.year  = year;
    _date.mon   = month - 1;
    _date.mday  = day;
    _date.hour  = hour;
    _date.min   = min;
    _date.sec   = sec;
    _date.isdst = isdst;
    _hasEpoch   = false;
    _hasDate    = true;
    _normalized = false;
    if (_rangeCheck) validateRange();
    return _error;
}

inline void Date::set (const Date* source, tz* zone) {
    _error = source->_error;
    if (_zone != NULL) tzfree(_zone);
    
    if (zone == NULL || _error) {
        _hasEpoch   = source->_hasEpoch;
        _hasDate    = source->_hasDate;
        _normalized = source->_normalized;
        _zone       = source->_zone;
        _epoch      = source->_epoch;
        if (_hasDate) _date  = source->_date;
    } else {
        _hasEpoch   = false;
        _hasDate    = true;
        _normalized = source->_normalized;
        _date       = source->_date;
        _zone       = zone;
    }
    
    tzcapture(_zone);
}

inline int Date::change (int32_t year, ptime_t mon, ptime_t day, ptime_t hour, ptime_t min, ptime_t sec, int isdst, tz* zone) {
    dCheck();
    _error = E_OK;
    if (year >= 0) _date.year = year;
    if (mon   > 0) _date.mon  = mon - 1;
    if (day   > 0) _date.mday = day;
    if (hour >= 0) _date.hour = hour;
    if (min  >= 0) _date.min  = min;
    if (sec  >= 0) _date.sec  = sec;
    _date.isdst = isdst;
    _hasEpoch   = false;
    _normalized = false;
    _zone_set(zone);
    if (_rangeCheck) validateRange();
    return _error;
}

inline void Date::_zone_set (tz* zone) {
    if (_zone == NULL) {
        if (zone == NULL) _zone = tzlocal();
        else _zone = zone;
        tzcapture(_zone);
    } else if (zone != NULL) {
        tzfree(_zone);
        tzcapture(zone);
        _zone = zone;
    }
}

inline void Date::eCheck () { if (!_hasEpoch) eSync(); }
inline void Date::dCheck () { if (!_hasDate || !_normalized) dSync(); }

inline ptime_t Date::epoch ()            { eCheck(); return _epoch; }
inline void    Date::epoch (ptime_t val) { _epoch = val; _hasEpoch = true; _hasDate = false; _normalized = false; }

inline const dt* Date::date       ()            { dCheck(); return &_date; }
inline bool      Date::hasEpoch   () const      { return _hasEpoch; }
inline bool      Date::hasDate    () const      { return _hasDate; }
inline bool      Date::normalized () const      { return _normalized; }
inline uint8_t   Date::error      () const      { return _error; }
inline void      Date::error      (uint8_t val) { _error = val; epoch(0); }
inline tz*       Date::timezone   () const      { return _zone; }

inline void Date::timezone (tz* zone) {
    dCheck();
    _hasEpoch = false;
    _normalized = false;
    if (zone == NULL) zone = tzlocal();
    _zone_set(zone);
}

inline void Date::toTimezone (tz* zone) {
    eCheck();
    _hasDate = false;
    _normalized = false;
    if (zone == NULL) zone = tzlocal();
    _zone_set(zone);
}

inline int32_t Date::year  ()            { dCheck(); return _date.year; }
inline void    Date::year  (int32_t val) { dCheck(); _date.year = val; _hasEpoch = false; _normalized = false; }
inline int32_t Date::_year ()            { return year() - 1900; }
inline void    Date::_year (int32_t val) { year(val + 1900); }
inline int8_t  Date::yr    ()            { return year() % 100; }
inline void    Date::yr    (int val)     { year( year() - yr() + val ); }

inline uint8_t Date::month  ()            { dCheck(); return _date.mon + 1; }
inline void    Date::month  (ptime_t val) { dCheck(); _date.mon = val - 1; _hasEpoch = false; _normalized = false; }
inline uint8_t Date::_month ()            { return month() - 1; }
inline void    Date::_month (ptime_t val) { month(val + 1); }

inline uint8_t Date::mday ()            { dCheck(); return _date.mday; }
inline void    Date::mday (ptime_t val) { dCheck(); _date.mday = val; _hasEpoch = false; _normalized = false; }
inline uint8_t Date::day  ()            { return mday(); }
inline void    Date::day  (ptime_t val) { mday(val); }

inline uint8_t Date::hour ()            { dCheck(); return _date.hour; }
inline void    Date::hour (ptime_t val) { dCheck(); _date.hour = val; _hasEpoch = false; _normalized = false; }

inline uint8_t Date::min ()            { dCheck(); return _date.min; }
inline void    Date::min (ptime_t val) { dCheck(); _date.min = val; _hasEpoch = false; _normalized = false; }

inline uint8_t Date::sec ()            { dCheck(); return _date.sec; }
inline void    Date::sec (ptime_t val) { dCheck(); _date.sec = val; _hasEpoch = false; _normalized = false; }

inline uint8_t Date::wday ()             { dCheck(); return _date.wday + 1; }
inline void    Date::wday (ptime_t val)  { dCheck(); _date.mday += val - (_date.wday + 1); _hasEpoch = false; _normalized = false; }
inline uint8_t Date::_wday ()            { return wday() - 1; }
inline void    Date::_wday (ptime_t val) { wday(val + 1); }
inline uint8_t Date::ewday ()            { dCheck(); return _date.wday == 0 ? 7 : _date.wday; }
inline void    Date::ewday (ptime_t val) { _date.mday += val - ewday(); _hasEpoch = false; _normalized = false; }

inline uint16_t Date::yday  ()            { dCheck(); return _date.yday + 1; }
inline void     Date::yday  (ptime_t val) { dCheck(); _date.mday += val - 1 - _date.yday; _hasEpoch = false; _normalized = false; }
inline uint16_t Date::_yday ()            { return yday() - 1; }
inline void     Date::_yday (ptime_t val) { yday(val + 1); }

inline bool        Date::isdst  () { dCheck(); return _date.isdst > 0 ? true : false; }
inline int32_t     Date::gmtoff () { dCheck(); return _date.gmtoff; }
inline const char* Date::tzabbr () { dCheck(); return _date.zone; }

inline int   Date::daysInMonth () { dCheck(); return days_in_month(_date.year, _date.mon); }
inline Date* Date::monthBegin  () { mday(1); return this; }
inline Date* Date::monthEnd    () { mday(daysInMonth()); return this; }

inline Date* Date::truncate () {
    dCheck();
    _date.sec  = 0;
    _date.min  = 0;
    _date.hour = 0;
    _hasEpoch   = false;
    _normalized = false;
    return this;
}

inline Date* Date::clone (tz* zone) const {
    return new Date(this, zone);
}

inline Date* Date::clone (int32_t year, ptime_t mon, ptime_t day, ptime_t hour, ptime_t min, ptime_t sec, int isdst, tz* zone) const {
    Date* ret = clone();
    ret->change(year, mon, day, hour, min, sec, isdst, zone);
    return ret;
}

inline Date* Date::truncateNew   ()                       const { return clone()->truncate(); }
inline Date* Date::monthBeginNew ()                       const { return clone()->monthBegin(); }
inline Date* Date::monthEndNew   ()                       const { return clone()->monthEnd(); }
inline Date* Date::addNew        (const DateRel* operand) const { return clone()->add(operand); }
inline Date* Date::subtractNew   (const DateRel* operand) const { return clone()->subtract(operand); }

inline const char* Date::toString () {
    if (_error) return NULL;
    return _strfmt[0] == '\0' ? iso() : this->strftime(_strfmt, NULL, 0);
}

inline bool Date::equals (Date* operand) { return compare(operand) == 0; }
inline bool Date::lt     (Date* operand) { return compare(operand) == -1; }
inline bool Date::lte    (Date* operand) { return compare(operand) <= 0; }
inline bool Date::gt     (Date* operand) { return compare(operand) == 1; }
inline bool Date::gte    (Date* operand) { return compare(operand) >= 0; }

inline Date& Date::operator= (const Date& source) {
    if (this != &source) set(&source);
    return *this;
}

inline Date::~Date () {
    tzfree(_zone);
}

inline Date* Date::now   () { return new Date(); }
inline Date* Date::today () { return now()->truncate(); }

inline bool Date::rangeCheck ()         { return _rangeCheck; }
inline void Date::rangeCheck (bool val) { _rangeCheck = val; }

};};

#endif
