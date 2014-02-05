#include "Date.h"
#include "DateRel.h"

using panda::util::itoa;

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
    buf = itoa(_date.year);\
    len = strlen(buf);\
    if (_date.year >= 0 && _date.year <= 999) for (i = 0; i < 4 - len; i++) *(ptr++) = '0';\
    for (i = 0; i < len; i++) *(ptr++) = *(buf++);
    
#define TOSTR_MONTH TOSTR_VAL2(_date.mon+1)
#define TOSTR_DAY   TOSTR_VAL2(_date.mday)
#define TOSTR_HOUR  TOSTR_VAL2(_date.hour)
#define TOSTR_MIN   TOSTR_VAL2(_date.min)
#define TOSTR_SEC   TOSTR_VAL2(_date.sec)

#define TOSTR_AMPM\
    *(ptr++) = _date.hour < 12 ? 'A' : 'P';\
    *(ptr++) = 'M';

#define TOSTR_END\
    *(ptr++) = 0;\
    return ret;

namespace panda { namespace date {

void Date::eSync () { // w/o date normalization
    _hasEpoch = true;
    _epoch = itimeanyl(&_date, _zone);
}

void Date::dSync () {
    _normalized = true;
    if (_hasEpoch) { // no date -> calculate from epoch
        _hasDate = true;
        ianytime(_epoch, &_date, _zone);
    } else { // no epoch -> normalize from date (set epoch as a side effect as well)
        _hasEpoch = true;
        _epoch = itimeany(&_date, _zone);
    }
}

err_t Date::validateRange () {
    datetime old = _date;
    dSync();
    
    if (old.sec != _date.sec || old.min != _date.min || old.hour != _date.hour || old.mday != _date.mday ||
        old.mon != _date.mon || old.year != _date.year) {
        _error = E_RANGE;
        return E_RANGE;
    }
    
    return E_OK;
}

int Date::compare (Date* operand) {
    if (_zone != operand->_zone) return epoch_cmp(epoch(), operand->epoch());
    else if (_hasEpoch && operand->_hasEpoch) return epoch_cmp(_epoch, operand->_epoch);
    else return date_cmp(date(), operand->date());
}

Date* Date::add (const DateRel* operand) {
    dCheck();
    _date.sec  += operand->sec();
    _date.min  += operand->min();
    _date.hour += operand->hour();
    _date.mday += operand->day();
    _date.mon  += operand->month();
    _date.year += operand->year();
    dChgAuto();
    return this;
}

Date* Date::subtract (const DateRel* operand) {
    dCheck();
    _date.sec  -= operand->sec();
    _date.min  -= operand->min();
    _date.hour -= operand->hour();
    _date.mday -= operand->day();
    _date.mon  -= operand->month();
    _date.year -= operand->year();
    dChgAuto();
    return this;
}

char* Date::strftime (const char* format, char* buf, size_t maxsize) {
    dCheck();
    static char defbuf[1000];
    if (buf == NULL) {
        buf = defbuf;
        maxsize = 1000;
    }
    size_t reslen = panda::time::strftime(buf, maxsize, format, &_date);
    return reslen > 0 ? buf : NULL;
}

const char* Date::iso () {
    TOSTR_START(50);
    TOSTR_YEAR; TOSTR_DEL('-'); TOSTR_MONTH; TOSTR_DEL('-'); TOSTR_DAY; TOSTR_DEL(' ');
    TOSTR_HOUR; TOSTR_DEL(':'); TOSTR_MIN; TOSTR_DEL(':'); TOSTR_SEC;
    TOSTR_END;
}

const char* Date::mysql () {
    TOSTR_START(45);
    TOSTR_YEAR; TOSTR_MONTH; TOSTR_DAY; TOSTR_HOUR; TOSTR_MIN; TOSTR_SEC;
    TOSTR_END;
}

const char* Date::hms () {
    TOSTR_START(8); TOSTR_HOUR; TOSTR_DEL(':'); TOSTR_MIN; TOSTR_DEL(':'); TOSTR_SEC; TOSTR_END;
}

const char* Date::ymd () {
    TOSTR_START(41); TOSTR_YEAR; TOSTR_DEL('/'); TOSTR_MONTH; TOSTR_DEL('/'); TOSTR_DAY; TOSTR_END;
}

const char* Date::mdy () {
    TOSTR_START(41); TOSTR_MONTH; TOSTR_DEL('/'); TOSTR_DAY; TOSTR_DEL('/'); TOSTR_YEAR; TOSTR_END;
}

const char* Date::dmy () {
    TOSTR_START(41); TOSTR_DAY; TOSTR_DEL('/'); TOSTR_MONTH; TOSTR_DEL('/'); TOSTR_YEAR; TOSTR_END;
}

const char* Date::meridiam () {
    TOSTR_START(8);
    int hour = _date.hour % 12;
    if (hour == 0) hour = 12;
    TOSTR_VAL2(hour); TOSTR_DEL(':'); TOSTR_MIN; TOSTR_DEL(' '); TOSTR_AMPM;
    TOSTR_END;
}

const char* Date::ampm () {
    dCheck();
    return _date.hour < 12 ? "AM" : "PM";
}

const char* Date::errstr () const {
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

/////////   STATIC   ///////////////////////////////
char Date::_strfmt[] = "";
bool Date::_rangeCheck = false;

const char* Date::stringFormat () {
    if (_strfmt[0] == '\0') return NULL;
    return _strfmt;
}

void Date::stringFormat (const char* fmt) {
    if (fmt == NULL) _strfmt[0] = '\0';
    else strncpy(_strfmt, fmt, MAX_FMT);
}

};};
