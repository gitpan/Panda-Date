#ifndef pdate_DateInt_h_included
#define pdate_DateInt_h_included

#include "Date.h"

namespace panda { namespace date {

using panda::time::christ_days;

class Date;

class DateInt {
private:
    Date _from;
    Date _till;
    
    ptime_t hmsDiff ();

public: 
    DateInt  ();
    DateInt  (ptime_t, ptime_t);
    DateInt  (const Date*, const Date*);
    DateInt  (const char* str, size_t len = 0);
    ~DateInt ();
    
    void  set (ptime_t, ptime_t);
    void  set (const Date*, const Date*);
    err_t set (const char* str, size_t len = 0);

    err_t error () const;
    
    Date* from ();
    Date* till ();
    
    const char* toString();
    
    ptime_t  duration ();
    ptime_t  sec      ();
    ptime_t  imin     ();
    double   min      ();
    ptime_t  ihour    ();
    double   hour     ();
    ptime_t  iday     ();
    double   day      ();
    ptime_t  imonth   ();
    double   month    ();
    ptime_t  iyear    ();
    double   year     ();
    
    DateRel* relative ();
    
    DateInt* clone () const;
    
    DateInt* add         (const DateRel*);
    DateInt* addNew      (const DateRel*) const;
    DateInt* subtract    (const DateRel*);
    DateInt* subtractNew (const DateRel*) const;
    DateInt* negative    ();
    DateInt* negativeNew () const;
    int      compare     (DateInt*);
    bool     equals      (DateInt*);
    int      includes    (Date*);
};

inline DateInt::DateInt ()                                   : _from((ptime_t) 0), _till((ptime_t) 0)       {}
inline DateInt::DateInt (ptime_t from, ptime_t till)         : _from((ptime_t) from), _till((ptime_t) till) {}
inline DateInt::DateInt (const Date* from, const Date* till) : _from(from), _till(till)                     {}
inline DateInt::DateInt (const char* str, size_t len)        : _from((ptime_t) 0), _till((ptime_t) 0)       { set(str, len); }

inline void DateInt::set (ptime_t from, ptime_t till) {
    _from.set(from);
    _from.set(till);
}

inline void DateInt::set (const Date* from, const Date* till) {
    _from.set(from);
    _till.set(till);
}

inline err_t DateInt::error () const { return _from.error() == E_OK ? _till.error() : _from.error(); }

inline Date* DateInt::from () { return &_from; }
inline Date* DateInt::till () { return &_till; }

inline ptime_t DateInt::hmsDiff () {
    return (_till.hour() - _from.hour())*3600 + (_till.min() - _from.min())*60 + _till.sec() - _from.sec();
}

inline ptime_t DateInt::duration () { return error() ? 0 : (_till.epoch() - _from.epoch()); }
inline ptime_t DateInt::sec      () { return duration(); }
inline ptime_t DateInt::imin     () { return duration()/60; }
inline double  DateInt::min      () { return (double) duration()/60; }
inline ptime_t DateInt::ihour    () { return duration()/3600; }
inline double  DateInt::hour     () { return (double) duration()/3600; }

inline ptime_t DateInt::iday     () { return (ptime_t) day(); }
inline double  DateInt::day      () { return christ_days(_till.year()) + _till.yday() - christ_days(_from.year()) - _from.yday() + (double) hmsDiff() / 86400; }

inline ptime_t DateInt::imonth   () { return (ptime_t) month(); }
inline double  DateInt::month    () {
    return (_till.year() - _from.year())*12 + _till.month() - _from.month() + 
           (double) (_till.day() - _from.day() + (double) hmsDiff() / 86400) / _from.daysInMonth();
}

inline ptime_t DateInt::iyear    () { return (ptime_t) year(); }
inline double  DateInt::year     () { return month() / 12; }

inline DateInt* DateInt::clone () const { return new DateInt(&_from, &_till); }

inline DateInt* DateInt::add (const DateRel* operand) {
    _from.add(operand);
    _till.add(operand);
    return this;
}

inline DateInt* DateInt::subtract (const DateRel* operand) {
    _from.subtract(operand);
    _till.subtract(operand);
    return this;
}

inline DateInt* DateInt::negative () {
    //::std::swap(_from, _till); // slower
    char tmp[sizeof(_from)];
    memcpy(tmp, &_from, sizeof(_from));
    memcpy(&_from, &_till, sizeof(_from));
    memcpy(&_till, tmp, sizeof(_from));
    return this;
}

inline DateInt* DateInt::addNew      (const DateRel* operand) const { return clone()->add(operand); }
inline DateInt* DateInt::subtractNew (const DateRel* operand) const { return clone()->subtract(operand); }
inline DateInt* DateInt::negativeNew ()                       const { return new DateInt(&_till, &_from); }

inline int DateInt::compare (DateInt* operand) {
    return epoch_cmp(duration(), operand->duration());
}

inline bool DateInt::equals  (DateInt* operand) {
    return _from.equals(&operand->_from) && _till.equals(&operand->_till);
}

inline int DateInt::includes (Date* date) {
    if (_from.gt(date)) return 1;
    if (_till.lt(date)) return -1;
    return 0;
}

inline DateInt::~DateInt () {};

};};

#endif
