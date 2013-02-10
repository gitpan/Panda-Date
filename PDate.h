#ifndef PDate_h_included
#define PDate_h_included

#include <time.h>
#include "Date.h"
#include "error.h"
#include "normalize.h"
#include "parse.h"
#include "PDateRel.h"

#define NORM_YDAY    1  // normalize using yday instead of day+month
#define NORM_RCHECK  2  // normalize with range check (out of range error)
#define NORM_MBA     4  // normalize using month border adjust

#define PDATE_CLASS "Panda::Date"
#ifdef PDATE_WITH_INHERITANCE
#define PDATE_BLESS sv_reftype(SvRV(ST(0)), TRUE)
#else
#define PDATE_BLESS PDATE_CLASS
#endif

#define TOSTR_START(maxlen)\
    dCheck();\
    int i;\
    static char ret[maxlen+1];\
    char* ptr = ret;\
    char* buf;\
    size_t len;
    
#define TOSTR_DEL(char) *(ptr++) = char;

#define TOSTR_VAL2(val)\
    buf = itoa(val);\
    len = strlen(buf);\
    if ((val) < 10) *(ptr++) = '0';\
    for (i = 0; i < len; i++) *(ptr++) = *(buf++);

#define TOSTR_YEAR\
    buf = itoa(_data.tm_year + 1900);\
    len = strlen(buf);\
    if (_data.tm_year >= -1900 && _data.tm_year <= -901) for (i = 0; i < 4 - len; i++) *(ptr++) = '0';\
    for (i = 0; i < len; i++) *(ptr++) = *(buf++);
    
#define TOSTR_MONTH TOSTR_VAL2(_data.tm_mon+1)
#define TOSTR_DAY   TOSTR_VAL2(_data.tm_mday)
#define TOSTR_HOUR  TOSTR_VAL2(_data.tm_hour)
#define TOSTR_MIN   TOSTR_VAL2(_data.tm_min)
#define TOSTR_SEC   TOSTR_VAL2(_data.tm_sec)

#define TOSTR_AMPM\
    *(ptr++) = _data.tm_hour < 12 ? 'A' : 'P';\
    *(ptr++) = 'M';

#define TOSTR_END\
    *(ptr++) = 0;\
    return ret;

#define WDAY_CHANGE(wday,delta)\
    wday += delta % 7;\
    if (wday < 0) wday += 7;\
    else if (wday > 6) wday -= 7;
    
class PDateRel;

class PDate {
private:
    time_t   _epoch;
    tm       _data;
    bool     _hasEpoch;
    bool     _hasData;
    bool     _hasFullData;
    uint8_t  _error;

    void eCheck     ();
    void eSync      ();
    void dNorm      ();
    void dNorm      (uint8_t);
    void dCheck     ();
    void dCheckFull ();
    void dSync      ();

public: 
    static SV*         strfmtSV;
    static const char* strfmt;
    static bool        monthBorderAdjust;
    static bool        rangeCheck;

    static SV*    stringFormatSV ();
    static void   stringFormatSV (SV*);
    static PDate* now ();
    static PDate* today ();

    PDate (time_t from);
    PDate (const char*, size_t);
    PDate (SV* arg);
    PDate (PDate* from);
        
    struct tm * data        ();
    bool        hasEpoch    ();
    bool        hasData     ();
    bool        hasFullData ();
    uint8_t     error       ();
    void        error       (uint8_t);
    
    time_t epoch ();
    void   epoch (time_t val);

    int32_t  year ();
    void     year (int32_t);
    int32_t _year ();
    void    _year (int32_t);
    int8_t   yr   ();
    void     yr   (int8_t);

    uint8_t  month ();
    void     month (int32_t);
    uint8_t _month ();
    void    _month (int32_t);
    
    uint8_t day ();
    void    day (int32_t);
    
    uint8_t hour ();
    void    hour (int32_t);

    uint8_t min ();
    void    min (int32_t);

    uint8_t sec ();
    void    sec (int32_t);
    
    uint8_t  wday  ();
    void     wday  (uint8_t);
    uint8_t _wday  ();
    void    _wday  (uint8_t);
    uint8_t  ewday ();
    void     ewday (uint8_t);
    
    uint16_t  yday ();
    void      yday (uint32_t);
    uint16_t _yday ();
    void     _yday (uint32_t);
    
    bool        isdst    ();
    int32_t     tzoffset ();
    const char* tz       ();
    const char* tzdst    ();
    
    uint8_t daysInMonth ();
    
    void setFrom (SV*);
    void setFrom (AV*);
    void setFrom (HV*, bool);
    void setFrom (int32_t, int32_t, int32_t, int32_t, int32_t, int32_t);
    void setFrom (const char*, size_t);
    void setFrom (PDate*);
    void parseSQL (const char*, size_t);
    void setFromSTRP (const char*, size_t);
    
    const char* toString ();
    const char* sql ();
    const char* hms ();
    const char* ymd ();
    const char* mdy ();
    const char* dmy ();
    const char* meridiam ();
    const char* ampm ();
    char*       strFtime (const char*, char*, size_t);
    
    PDate* clone        ();
    PDate* truncate     ();
    PDate* truncateME   ();
    PDate* monthBegin   ();
    PDate* monthBeginME ();
    PDate* monthEnd     ();
    PDate* monthEndME   ();
    
    int       compare    (PDate*);
    PDate*    add        (PDateRel*);
    PDate*    addME      (PDateRel*);
    PDate*    subtract   (PDateRel*);
    PDate*    subtractME (PDateRel*);
    
    void _dbg ();
    
    const char* errstr ();
    
    ~PDate ();
};

#endif
