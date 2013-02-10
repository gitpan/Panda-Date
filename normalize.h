#ifndef normalize_h_included
#define normalize_h_included

#include "Date.h"

/*
 * classdate_mini_mktime - normalise struct tm values without the localtime()
 * semantics (and overhead) of mktime().
 */
void normalize (struct tm *ptm);

#endif
