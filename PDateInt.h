#ifndef PDateInt_h_included
#define PDateInt_h_included

#include <string.h>
#include "Date.h"
#include "error.h"
#include "parse.h"
#include "PDate.h"
#include "PDateRel.h"

#define PDATE_INT_CLASS "Panda::Date::Int"
#ifdef PDATE_WITH_INHERITANCE
#define PDATE_INT_BLESS sv_reftype(SvRV(ST(0)), TRUE)
#else
#define PDATE_INT_BLESS PDATE_INT_CLASS
#endif

class PDate;

class PDateInt {
private:
    PDate _from;
    PDate _till;
    
    void    check   ();
    int64_t hmsDiff ();

public: 
    PDateInt  ();
    PDateInt  (PDate*, PDate*);
    PDateInt  (SV*);
    PDateInt  (SV*, SV*);
    ~PDateInt ();
    
    void setFrom (SV*);
    void setFrom (SV*, SV*);
    bool setFrom (const char*, size_t);

    bool hasError ();
    
    PDate* from ();
    void   from (SV*);
    PDate* till ();
    void   till (SV*);
    
    const char* toString();
    
    int64_t  duration ();
    int64_t  sec      ();
    int64_t  imin     ();
    double   min      ();
    int64_t  ihour    ();
    double   hour     ();
    int64_t  iday     ();
    double   day      ();
    int64_t  imonth   ();
    double   month    ();
    int64_t  iyear    ();
    double   year     ();
    
    PDateRel* relative ();
    
    PDateInt* clone ();
    
    PDateInt* add        (PDateRel*);
    PDateInt* addME      (PDateRel*);
    PDateInt* subtract   (PDateRel*);
    PDateInt* subtractME (PDateRel*);
    PDateInt* negative   ();
    PDateInt* negativeME ();
    int       compare    (PDateInt*);
    bool      equals     (PDateInt*);
};

#endif
