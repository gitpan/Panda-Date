#ifndef pdate_DateRel_h_included
#define pdate_DateRel_h_included

#include <math.h>
#include "Date.h"

namespace panda { namespace date {

#define _PDR_CHKCONST if (_isConst) throw "pdate: cannot change this DateRel object: it's read only";

using panda::time::datetime;
    
class Date;

class DateRel {
private:
    ptime_t _sec;
    ptime_t _min;
    ptime_t _hour;
    ptime_t _day;
    ptime_t _month;
    ptime_t _year;
    bool    _isConst;

public: 
    DateRel (ptime_t year=0, ptime_t mon=0, ptime_t day=0, ptime_t hour=0, ptime_t min=0, ptime_t sec=0);
    DateRel (const DateRel*);
    DateRel (const DateRel&);
    DateRel (const dt*, const dt*);
    DateRel (const char* str, size_t len = 0);
    ~DateRel ();
    
    DateRel& operator= (const DateRel&);
    
    bool isConst () const;
    void isConst (bool);
    
    ptime_t sec   () const;
    void    sec   (ptime_t);
    ptime_t min   () const;
    void    min   (ptime_t);
    ptime_t hour  () const;
    void    hour  (ptime_t);
    ptime_t day   () const;
    void    day   (ptime_t);
    ptime_t month () const;
    void    month (ptime_t);
    ptime_t year  () const;
    void    year  (ptime_t);
    bool    empty () const;
    
    ptime_t toSec   () const;
    double  toMin   () const;
    double  toHour  () const;
    double  toDay   () const;
    double  toMonth () const;
    double  toYear  () const;
    
    ptime_t duration () const { return toSec(); }

    void set (const DateRel*);
    void set (const dt*, const dt*);
    int  set (const char* str, size_t len = 0);
    void set (ptime_t year, ptime_t mon=0, ptime_t day=0, ptime_t hour=0, ptime_t min=0, ptime_t sec=0);
    
    const char* toString () const;
    
    DateRel* clone       () const;
    DateRel* multiply    (double koef);
    DateRel* multiplyNew (double koef) const;
    DateRel* divide      (double koef);
    DateRel* divideNew   (double koef) const;
    DateRel* add         (const DateRel*);
    DateRel* addNew      (const DateRel*) const;
    DateRel* subtract    (const DateRel*);
    DateRel* subtractNew (const DateRel*) const;
    DateRel* negative    ();
    DateRel* negativeNew () const;
    int      compare     (const DateRel*) const;
    bool     equals      (const DateRel*) const;
};

inline DateRel::DateRel (ptime_t year, ptime_t mon, ptime_t day, ptime_t hour, ptime_t min, ptime_t sec) : _isConst(false) {
    set(year, mon, day, hour, min, sec);
};

inline DateRel::DateRel (const DateRel* source)          : _isConst(false) { set(source); }
inline DateRel::DateRel (const DateRel& source)          : _isConst(false) { set(&source); }
inline DateRel::DateRel (const dt* from, const dt* till) : _isConst(false) { set(from, till); }
inline DateRel::DateRel (const char* str, size_t len)    : _isConst(false) { set(str, len); }

inline bool DateRel::isConst () const   { return _isConst; }
inline void DateRel::isConst (bool val) { _PDR_CHKCONST; _isConst = val; }

inline ptime_t DateRel::sec   () const      { return _sec; }
inline void    DateRel::sec   (ptime_t val) { _PDR_CHKCONST; _sec = val; }
inline ptime_t DateRel::min   () const      { return _min; }
inline void    DateRel::min   (ptime_t val) { _PDR_CHKCONST; _min = val; }
inline ptime_t DateRel::hour  () const      { return _hour; }
inline void    DateRel::hour  (ptime_t val) { _PDR_CHKCONST; _hour = val; }
inline ptime_t DateRel::day   () const      { return _day; }
inline void    DateRel::day   (ptime_t val) { _PDR_CHKCONST; _day = val; }
inline ptime_t DateRel::month () const      { return _month; }
inline void    DateRel::month (ptime_t val) { _PDR_CHKCONST; _month = val; }
inline ptime_t DateRel::year  () const      { return _year; }
inline void    DateRel::year  (ptime_t val) { _PDR_CHKCONST; _year = val; }
inline bool    DateRel::empty () const      { return _sec == 0 && _min == 0 && _hour == 0 && _day == 0 && _month == 0 && _year == 0; }

inline ptime_t DateRel::toSec   () const { return _sec + _min*60 + _hour*3600 + _day * 86400 + (_month + 12*_year) * 2629744; }
inline double  DateRel::toMin   () const { return (double) toSec() / 60; }
inline double  DateRel::toHour  () const { return (double) toSec() / 3600; }
inline double  DateRel::toDay   () const { return (double) toSec() / 86400; }
inline double  DateRel::toMonth () const { return (double) toSec() / 2629744; }
inline double  DateRel::toYear  () const { return toMonth() / 12; }

inline void DateRel::set (ptime_t year, ptime_t mon, ptime_t day, ptime_t hour, ptime_t min, ptime_t sec) {
    _PDR_CHKCONST;
    _year  = year;
    _month = mon;
    _day   = day;
    _hour  = hour;
    _min   = min;
    _sec   = sec;
}

inline void DateRel::set (const DateRel* source) {
    _PDR_CHKCONST;
    _sec   = source->_sec;
    _min   = source->_min;
    _hour  = source->_hour;
    _day   = source->_day;
    _month = source->_month;
    _year  = source->_year;
}

inline int DateRel::set (const char* str, size_t len) {
    _PDR_CHKCONST;
    datetime date;
    int error = parse_relative(str, len, &date);
    if (error) return error;
    _year  = date.year;
    _month = date.mon;
    _day   = date.mday;
    _hour  = date.hour;
    _min   = date.min;
    _sec   = date.sec;
    return E_OK;
}

inline DateRel* DateRel::clone () const { return new DateRel(this); }

inline DateRel* DateRel::multiplyNew (double koef)            const { return clone()->multiply(koef); }
inline DateRel* DateRel::divideNew   (double koef)            const { return clone()->divide(koef); }
inline DateRel* DateRel::addNew      (const DateRel* operand) const { return clone()->add(operand); }
inline DateRel* DateRel::subtractNew (const DateRel* operand) const { return clone()->subtract(operand); }
inline DateRel* DateRel::negativeNew ()                       const { return clone()->negative(); }

inline int DateRel::compare (const DateRel* operand) const {
    return epoch_cmp(toSec(), operand->toSec());
}

inline bool DateRel::equals (const DateRel* operand) const {
    return _sec == operand->_sec && _min == operand->_min && _hour == operand->_hour &&
           _day == operand->_day && _month == operand->_month && _year == operand->_year;
}

inline DateRel& DateRel::operator= (const DateRel& source) {
    if (this != &source) set(&source);
    return *this;
}

inline DateRel::~DateRel () {};

};};

#endif
