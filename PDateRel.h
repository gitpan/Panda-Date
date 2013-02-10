#ifndef PDateRel_h_included
#define PDateRel_h_included

#include <string.h>
#include <math.h>
#include "Date.h"
#include "error.h"
#include "parse.h"
#include "PDate.h"

#define PDATE_REL_CLASS "Panda::Date::Rel"
#ifdef PDATE_WITH_INHERITANCE
#define PDATE_REL_BLESS sv_reftype(SvRV(ST(0)), TRUE)
#else
#define PDATE_REL_BLESS PDATE_REL_CLASS
#endif

#define RELSTR_START(maxlen)\
    int i;\
    static char ret[maxlen+1];\
    char* ptr = ret;\
    char* buf;
    
#define RELSTR_VAL(val,units)\
    if (ptr != ret) *(ptr++) = ' ';\
    buf = itoa(val);\
    while (*buf) *(ptr++) = *(buf++);\
    *(ptr++) = units;

#define RELSTR_END\
    *(ptr++) = 0;\
    return ret;
    
class PDate;

class PDateRel {
private:
    int64_t _sec;
    int64_t _min;
    int64_t _hour;
    int64_t _day;
    int64_t _month;
    int64_t _year;

public: 
    PDateRel  ();
    PDateRel  (PDateRel*);
    PDateRel  (SV*);
    PDateRel  (SV*, SV*);
    PDateRel  (struct tm&, struct tm&);
    ~PDateRel ();
    
    int64_t sec   ();
    void    sec   (int64_t);
    int64_t min   ();
    void    min   (int64_t);
    int64_t hour  ();
    void    hour  (int64_t);
    int64_t day   ();
    void    day   (int64_t);
    int64_t month ();
    void    month (int64_t);
    int64_t year  ();
    void    year  (int64_t);
    
    int64_t toSec   ();
    double  toMin   ();
    double  toHour  ();
    double  toDay   ();
    double  toMonth ();
    double  toYear  ();
    
    void setFrom (SV*);
    void setFrom (HV*);
    void setFrom (AV*);
    void setFrom (const char*, size_t);
    void setFrom (struct tm&, struct tm&);
    void setFrom (SV*, SV*);
    void setFrom (PDateRel*);
    
    const char* toString ();
    bool empty ();
    bool hasMPart ();
    bool hasSPart ();
    
    PDateRel* clone      ();
    PDateRel* multiply   (double koef);
    PDateRel* multiplyME (double koef);
    PDateRel* divide     (double koef);
    PDateRel* divideME   (double koef);
    PDateRel* add        (PDateRel*);
    PDateRel* addME      (PDateRel*);
    PDateRel* subtract   (PDateRel*);
    PDateRel* subtractME (PDateRel*);
    PDateRel* negative   ();
    PDateRel* negativeME ();
    int       compare    (PDateRel*);
    bool      equals     (PDateRel*);
};

#endif
