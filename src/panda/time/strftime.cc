#include <panda/time/strftime.h>

namespace panda { namespace time {

size_t strftime (char* buf, size_t maxsize, const char* format, const dt* timeptr) {
    struct tm tptr;
    tptr.tm_sec    = timeptr->sec;
    tptr.tm_min    = timeptr->min;
    tptr.tm_hour   = timeptr->hour;
    tptr.tm_mday   = timeptr->mday;
    tptr.tm_mon    = timeptr->mon;
    tptr.tm_year   = timeptr->year - 1900;
    tptr.tm_yday   = timeptr->yday;
    tptr.tm_wday   = timeptr->wday;
    tptr.tm_isdst  = timeptr->isdst;
#ifndef PTIME_OSTYPE_WIN
    tptr.tm_gmtoff = timeptr->gmtoff;
    tptr.tm_zone   = (char*) timeptr->zone;
#endif
    return strftime(buf, maxsize, format, &tptr);
}

void printftime (const char* format, const dt* timeptr) {
    char buf[150];
    strftime(buf, 150, format, timeptr);
    printf("%s", buf);
}

void printftime (const char* format, const struct tm* timeptr) {
    char buf[150];
    strftime(buf, 150, format, timeptr);
    printf("%s", buf);
}

}}
