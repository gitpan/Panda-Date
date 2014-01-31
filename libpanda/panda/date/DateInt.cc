#include "inc.h"
#include "DateInt.h"
#include "DateRel.h"

namespace panda { namespace date {

int DateInt::set (const char* str, size_t len) {
    if (len < 1) len = strlen(str);
    char* ptr = (char*) str;
    char* from_str = strsep(&ptr, "~");
    if (ptr == NULL || ptr >= str + len - 1) return E_UNPARSABLE;
    int error1 = _from.set(from_str, strlen(from_str));
    int error2 = _till.set(ptr+1, strlen(ptr)-1);
    if (error1) return error1;
    else if (error2) return error2;
    return E_OK;
}

const char* DateInt::toString () {
    if (error()) return NULL;
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

DateRel* DateInt::relative () { return new DateRel(_from.date(), _till.date()); }

};};
