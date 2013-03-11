#include "PDate.h"
#include "PDateInt.h"

MODULE = Panda::Date                PACKAGE = Panda::Date
PROTOTYPES: DISABLE

#///////////////////////////// STATIC FUNCTIONS ///////////////////////////////////
 
PDate *
now (...)
CODE:
    RETVAL = PDate::now();
    const char* CLASS = PDATE_CLASS;
OUTPUT:
    RETVAL


PDate *
today (...)
CODE:
    RETVAL = PDate::today();
    const char* CLASS = PDATE_CLASS;
OUTPUT:
    RETVAL


uint64_t
today_epoch (...)
CODE:
    PDate date((time_t) 0);
    date.epoch(time(NULL));
    date.truncateME();
    RETVAL = date.epoch();
OUTPUT:
    RETVAL


PDate *
date (SV* arg)
CODE:
    RETVAL = new PDate(arg);
    const char* CLASS = PDATE_CLASS;
OUTPUT:
    RETVAL


SV*
string_format (...)
CODE:
    if (items > 1) PDate::stringFormatSV(ST(1));
    RETVAL = PDate::stringFormatSV();
    if (RETVAL == NULL) XSRETURN_UNDEF;
    SvREFCNT_inc(RETVAL);
OUTPUT:
    RETVAL
    

bool
month_border_adjust (...)
CODE:
    if (items > 1) PDate::monthBorderAdjust = SvTRUE(ST(1));
    RETVAL = PDate::monthBorderAdjust;
OUTPUT:
    RETVAL


bool
range_check (...)
CODE:
    if (items > 1) PDate::rangeCheck = SvTRUE(ST(1));
    RETVAL = PDate::rangeCheck;
OUTPUT:
    RETVAL

#///////////////////////////// OBJECT METHODS ///////////////////////////////////

PDate *
PDate::new (SV* arg)
CODE:
    RETVAL = new PDate(arg);
OUTPUT:
    RETVAL


void
PDate::set_from (SV* arg)
PPCODE:
    THIS->setFrom(arg);
    XSRETURN(0);


time_t
PDate::epoch (...)
CODE:
    if (items > 1) THIS->epoch(SvIV(ST(1)));
    RETVAL = THIS->epoch();
OUTPUT:
    RETVAL
    
    
int32_t
PDate::year (...)
CODE:
    if (items > 1) THIS->year(SvIV(ST(1)));
    RETVAL = THIS->year();
OUTPUT:
    RETVAL
    

int32_t
PDate::_year (...)
CODE:
    if (items > 1) THIS->_year(SvIV(ST(1)));
    RETVAL = THIS->_year();
OUTPUT:
    RETVAL


int8_t
PDate::yr (...)
CODE:
    if (items > 1) THIS->yr(SvIV(ST(1)));
    RETVAL = THIS->yr();
OUTPUT:
    RETVAL


uint8_t
PDate::month (...)
ALIAS:
    mon = 1
CODE:
    if (items > 1) THIS->month(SvIV(ST(1)));
    RETVAL = THIS->month();
OUTPUT:
    RETVAL


uint8_t
PDate::_month (...)
ALIAS:
    _mon = 1
CODE:
    if (items > 1) THIS->_month(SvIV(ST(1)));
    RETVAL = THIS->_month();
OUTPUT:
    RETVAL
    

uint8_t
PDate::day (...)
ALIAS:
    mday = 1
    day_of_month = 2
CODE:
    if (items > 1) THIS->day(SvIV(ST(1)));
    RETVAL = THIS->day();
OUTPUT:
    RETVAL


uint8_t
PDate::hour (...)
CODE:
    if (items > 1) THIS->hour(SvIV(ST(1)));
    RETVAL = THIS->hour();
OUTPUT:
    RETVAL


uint8_t
PDate::min (...)
ALIAS:
    minute = 1
CODE:
    if (items > 1) THIS->min(SvIV(ST(1)));
    RETVAL = THIS->min();
OUTPUT:
    RETVAL


uint8_t
PDate::sec (...)
ALIAS:
    second = 1
CODE:
    if (items > 1) THIS->sec(SvIV(ST(1)));
    RETVAL = THIS->sec();
OUTPUT:
    RETVAL


uint8_t
PDate::wday (...)
ALIAS:
    day_of_week = 1
CODE:
    if (items > 1) THIS->wday(SvUV(ST(1)));
    RETVAL = THIS->wday();
OUTPUT:
    RETVAL
    

uint8_t
PDate::_wday (...)
CODE:
    if (items > 1) THIS->_wday(SvUV(ST(1)));
    RETVAL = THIS->_wday();
OUTPUT:
    RETVAL


uint8_t
PDate::ewday (...)
CODE:
    if (items > 1) THIS->ewday(SvUV(ST(1)));
    RETVAL = THIS->ewday();
OUTPUT:
    RETVAL


uint16_t
PDate::yday (...)
ALIAS:
    day_of_year = 1
CODE:
    if (items > 1) THIS->yday(SvUV(ST(1)));
    RETVAL = THIS->yday();
OUTPUT:
    RETVAL


uint16_t
PDate::_yday (...)
CODE:
    if (items > 1) THIS->_yday(SvUV(ST(1)));
    RETVAL = THIS->_yday();
OUTPUT:
    RETVAL


bool
PDate::isdst ()
ALIAS:
    daylight_savings = 1
CODE:
    RETVAL = THIS->isdst();
OUTPUT:
    RETVAL


const char*
PDate::to_string (...)
ALIAS:
    as_string = 1
    string = 2
CODE:
    RETVAL = THIS->toString();
    if (RETVAL == NULL) XSRETURN_UNDEF;
OUTPUT:
    RETVAL
    

bool
PDate::to_bool (...)
CODE:
    RETVAL = THIS->error() == E_OK ? true : false;
OUTPUT:
    RETVAL


int64_t
PDate::to_number (...)
CODE:
    RETVAL = THIS->error() == E_OK ? THIS->epoch() : 0;
OUTPUT:
    RETVAL


const char*
PDate::strftime (const char* format)
CODE:
    RETVAL = THIS->strFtime(format, NULL, 0);
    if (RETVAL == NULL) XSRETURN_UNDEF;
OUTPUT:
    RETVAL


const char*
PDate::monthname ()
ALIAS:
    monname = 1
CODE:
    RETVAL = THIS->strFtime("%B", NULL, 0);
    if (RETVAL == NULL) XSRETURN_UNDEF;
OUTPUT:
    RETVAL


const char*
PDate::wdayname ()
ALIAS:
    day_of_weekname = 1
CODE:
    RETVAL = THIS->strFtime("%A", NULL, 0);
    if (RETVAL == NULL) XSRETURN_UNDEF;
OUTPUT:
    RETVAL


const char*
PDate::iso ()
ALIAS:
    sql = 1
CODE:
    RETVAL = THIS->iso();
OUTPUT:
    RETVAL


const char*
PDate::mysql ()
CODE:
    RETVAL = THIS->mysql();
OUTPUT:
    RETVAL


const char*
PDate::hms ()
CODE:
    RETVAL = THIS->hms();
OUTPUT:
    RETVAL


const char*
PDate::ymd ()
CODE:
    RETVAL = THIS->ymd();
OUTPUT:
    RETVAL    


const char*
PDate::mdy ()
CODE:
    RETVAL = THIS->mdy();
OUTPUT:
    RETVAL


const char*
PDate::dmy ()
CODE:
    RETVAL = THIS->dmy();
OUTPUT:
    RETVAL


const char*
PDate::ampm ()
CODE:
    RETVAL = THIS->ampm();
OUTPUT:
    RETVAL


const char*
PDate::meridiam ()
CODE:
    RETVAL = THIS->meridiam();
OUTPUT:
    RETVAL


int32_t
PDate::tzoffset ()
CODE:
    RETVAL = THIS->tzoffset();
OUTPUT:
    RETVAL


const char*
PDate::tz ()
CODE:
    RETVAL = THIS->tz();
OUTPUT:
    RETVAL
    

const char*
PDate::tzdst ()
CODE:
    RETVAL = THIS->tzdst();
OUTPUT:
    RETVAL


void
PDate::array ()
PPCODE:
    EXTEND(SP, 6);
    mPUSHi(THIS->year());
    mPUSHu(THIS->month());
    mPUSHu(THIS->day());
    mPUSHu(THIS->hour());
    mPUSHu(THIS->min());
    mPUSHu(THIS->sec());
    XSRETURN(6);


AVR
PDate::aref ()
CODE:
    RETVAL = newAV();
    av_extend(RETVAL, 5);
    av_store(RETVAL, 0, newSViv(THIS->year()));
    av_store(RETVAL, 1, newSVuv(THIS->month()));
    av_store(RETVAL, 2, newSVuv(THIS->day()));
    av_store(RETVAL, 3, newSVuv(THIS->hour()));
    av_store(RETVAL, 4, newSVuv(THIS->min()));
    av_store(RETVAL, 5, newSVuv(THIS->sec()));
OUTPUT:
    RETVAL


void
PDate::struct ()
PPCODE:
    EXTEND(SP, 9);
    mPUSHu(THIS->sec());
    mPUSHu(THIS->min());
    mPUSHu(THIS->hour());
    mPUSHu(THIS->day());
    mPUSHu(THIS->_month());
    mPUSHi(THIS->_year());
    mPUSHu(THIS->_wday());
    mPUSHu(THIS->_yday());
    mPUSHu(THIS->isdst() ? 1 : 0);
    XSRETURN(9);


AVR
PDate::sref ()
CODE:
    RETVAL = newAV();
    av_extend(RETVAL, 8);
    av_store(RETVAL, 0, newSVuv(THIS->sec()));
    av_store(RETVAL, 1, newSVuv(THIS->min()));
    av_store(RETVAL, 2, newSVuv(THIS->hour()));
    av_store(RETVAL, 3, newSVuv(THIS->day()));
    av_store(RETVAL, 4, newSVuv(THIS->_month()));
    av_store(RETVAL, 5, newSViv(THIS->_year()));
    av_store(RETVAL, 6, newSVuv(THIS->_wday()));
    av_store(RETVAL, 7, newSVuv(THIS->_yday()));
    av_store(RETVAL, 8, newSVuv(THIS->isdst() ? 1 : 0));
OUTPUT:
    RETVAL


void
PDate::hash ()
PPCODE:
    EXTEND(SP, 12);
    mPUSHp("year", 4);
    mPUSHi(THIS->year());
    mPUSHp("month", 5);
    mPUSHu(THIS->month());
    mPUSHp("day", 3);
    mPUSHu(THIS->day());
    mPUSHp("hour", 4);
    mPUSHu(THIS->hour());
    mPUSHp("min", 3);
    mPUSHu(THIS->min());
    mPUSHp("sec", 3);
    mPUSHu(THIS->sec());
    XSRETURN(12);


HVR
PDate::href ()
CODE:
    RETVAL = newHV();
    hv_store(RETVAL, "year",  4, newSViv(THIS->year()), 0);
    hv_store(RETVAL, "month", 5, newSVuv(THIS->month()), 0);
    hv_store(RETVAL, "day",   3, newSVuv(THIS->day()), 0);
    hv_store(RETVAL, "hour",  4, newSVuv(THIS->hour()), 0);
    hv_store(RETVAL, "min",   3, newSVuv(THIS->min()), 0);
    hv_store(RETVAL, "sec",   3, newSVuv(THIS->sec()), 0);
OUTPUT:
    RETVAL


PDate*
PDate::clone (...)
CODE:
    RETVAL = THIS->clone();
    const char* CLASS = PDATE_BLESS;
    if (items > 1) {
        SV* arg = ST(1);
        if (!SvROK(arg)) croak("Panda::Date::clone: wrong parameter type");
        HV* val = (HV*) SvRV(arg);
        if (SvTYPE(val) != SVt_PVHV) croak("Panda::Date::clone: wrong parameter type");
        RETVAL->setFrom(val, true);
    }
OUTPUT:
    RETVAL


SV*
PDate::month_begin_me ()
PPCODE:
    THIS->monthBeginME();
    XSRETURN(1);


PDate*
PDate::month_begin ()
CODE:
    RETVAL = THIS->monthBegin();
    const char* CLASS = PDATE_BLESS;
OUTPUT:
    RETVAL


SV*
PDate::month_end_me ()
PPCODE:
    THIS->monthEndME();
    XSRETURN(1);


PDate*
PDate::month_end ()
CODE:
    RETVAL = THIS->monthEnd();
    const char* CLASS = PDATE_BLESS;
OUTPUT:
    RETVAL


uint8_t
PDate::days_in_month ()
CODE:
    RETVAL = THIS->daysInMonth();
OUTPUT:
    RETVAL


uint8_t
PDate::error ()
CODE:
    RETVAL = THIS->error();
OUTPUT:
    RETVAL


const char*
PDate::errstr ()
CODE:
    RETVAL = THIS->errstr();
    if (RETVAL == NULL) XSRETURN_UNDEF;
OUTPUT:
    RETVAL


SV*
PDate::truncate_me ()
PPCODE:
    THIS->truncateME();
    XSRETURN(1);
    

PDate *
PDate::truncate ()
CODE:
    const char* CLASS = PDATE_BLESS;
    RETVAL = THIS->truncate();
OUTPUT:
    RETVAL


void
PDate::_dbg ()
PPCODE:
    THIS->_dbg();
    XSRETURN_EMPTY;


int
PDate::compare (SV* arg, bool reverse)
CODE:
    static PDate acc((time_t) 0);
    PDate* operand;
    if (sv_isobject(arg)) {
        if (sv_isa(arg, PDATE_CLASS)) operand = (PDate *) SvIV(SvRV(arg));
        else croak("Panda::Date: cannot '<=>' or 'cmp' - object isn't a Panda::Date object");
    }
    else {
        acc.setFrom(arg);
        operand = &acc;
    }
    
    RETVAL = THIS->compare(operand);
    if (reverse) RETVAL *= -1;
OUTPUT:
    RETVAL    


PDate*
PDate::add (SV* arg, ...)
CODE:
    static PDateRel acc;
    PDateRel* operand = NULL;
    if (sv_isobject(arg)) {
        if (sv_isa(arg, PDATE_REL_CLASS)) operand = (PDateRel *) SvIV(SvRV(arg));
        else croak("Panda::Date: cannot '+' - object isn't a Panda::Date::Rel object");
    }
    else {
        acc.setFrom(arg);
        operand = &acc;
    }
    const char* CLASS = PDATE_BLESS;
    RETVAL = THIS->add(operand);
OUTPUT:
    RETVAL


SV*
PDate::add_me (SV* arg, ...)
PPCODE:
    static PDateRel acc;
    PDateRel* operand = NULL;
    if (sv_isobject(arg)) {
        if (sv_isa(arg, PDATE_REL_CLASS)) operand = (PDateRel *) SvIV(SvRV(arg));
        else croak("Panda::Date: cannot '+=' - object isn't a Panda::Date::Rel object");
    }
    else {
        acc.setFrom(arg);
        operand = &acc;
    }

    THIS->addME(operand);
    XSRETURN(1);


PDate*
PDate::subtract (SV* arg, bool reverse)
CODE:
    char* CLASS;
    static PDate opDate((time_t) 0);
    static PDateRel opRel;
    
    if (sv_isobject(arg)) { // reverse is impossible here
        if (sv_isa(arg, PDATE_REL_CLASS)) {
            RETVAL = THIS->subtract((PDateRel *) SvIV(SvRV(arg)));
            CLASS = (char*) PDATE_BLESS;
        }
        else if (sv_isa(arg, PDATE_CLASS)) {
            PDate* date = (PDate *) SvIV(SvRV(arg));
            RETVAL = (PDate*) new PDateInt(date, THIS);
            CLASS = (char*) PDATE_INT_CLASS;
        }
        else croak("Panda::Date: cannot '-' unsupported object type");
    }
    else if (reverse) { // only date supported for reverse
        opDate.setFrom(arg);
        RETVAL = (PDate*) new PDateInt(THIS, &opDate);
        CLASS = (char*) PDATE_INT_CLASS;
    }
    else { // date or rdate scalar
        const char* argstr = SvPV_nolen(arg);
        if (strchr(argstr, '-') == NULL) { // not a date -> reldate
            opRel.setFrom(arg);
            RETVAL = THIS->subtract(&opRel);
            CLASS = (char*) PDATE_BLESS;
        } else { // date
            opDate.setFrom(arg);
            RETVAL = (PDate*) new PDateInt(&opDate, THIS);
            CLASS = (char*) PDATE_INT_CLASS;
        }
    }
OUTPUT:
    RETVAL


SV*
PDate::subtract_me (SV* arg, ...)
PPCODE:
    static PDateRel acc;
    PDateRel* operand = NULL;
    if (sv_isobject(arg)) {
        if (sv_isa(arg, PDATE_REL_CLASS)) operand = (PDateRel *) SvIV(SvRV(arg));
        else croak("Panda::Date: cannot '-=' unsupported object type");
    }
    else {
        acc.setFrom(arg);
        operand = &acc;
    }

    THIS->subtractME(operand);
    XSRETURN(1);


const char*
PDate::STORABLE_freeze (bool cloning)
CODE:
    RETVAL = THIS->toString();
OUTPUT:
    RETVAL


PDate*
STORABLE_attach (const char* CLASS, bool cloning, SV* serialized)
CODE:
    STRLEN len;
    const char* str = SvPV(serialized, len);
    RETVAL = new PDate(str, len);
OUTPUT:
    RETVAL


void
PDate::DESTROY ()


INCLUDE: DateRel.xsi
INCLUDE: DateInt.xsi
