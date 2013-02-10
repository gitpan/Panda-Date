#ifndef parse_h_included
#define parse_h_included

#include "Date.h"
#include "error.h"

uint8_t parse_sql      (const char*, size_t, struct tm &);
uint8_t parse_relative (const char*, size_t, struct tm &);

#endif
