#include "parse.h"

#define STATE_YEAR  0
#define STATE_MONTH 1
#define STATE_DAY   2
#define STATE_HOUR  3
#define STATE_MIN   4
#define STATE_SEC   5

uint8_t parse_sql (const char* str, size_t len, struct tm &date) {
    int state = STATE_YEAR;
    int32_t curval = 0;
    for (int i = 0; i <= len; i++) {
        char c = i == len ? '-' : str[i];
        if (c >= '0' and c <= '9') {
            curval *= 10;
            curval += (c-48);
        }
        else if (c == '-' || c == ' ' || c == ':' || c == '.' || c == '\n' || c == 0) {
            switch (state) {
                case STATE_YEAR:
                    date.tm_year = curval - 1900;
                    break;
                case STATE_MONTH:
                    date.tm_mon = (curval == 0 ? 1 : curval) - 1;
                    break;
                case STATE_DAY:
                    date.tm_mday = curval == 0 ? 1 : curval;
                    break;
                case STATE_HOUR:
                    date.tm_hour = curval;
                    break;
                case STATE_MIN:
                    date.tm_min = curval;
                    break;
                case STATE_SEC:
                    date.tm_sec = curval;
                    break;
            }
            state++;
            curval = 0;
        }
        else return E_UNPARSABLE;
    }

    switch (state) { // fill absent fields with defaults
        case STATE_MONTH:
            date.tm_mon = 0;
        case STATE_DAY:
            date.tm_mday = 1;
        case STATE_HOUR:
            date.tm_hour = 0;
        case STATE_MIN:
            date.tm_min = 0;
        case STATE_SEC:
            date.tm_sec = 0;
    }
    
    return E_OK;
}

uint8_t parse_relative (const char* str, size_t len, struct tm &date) {
    memset(&date, 0, sizeof(date)); // reset all values
    int64_t curval = 0;
    bool negative = false;
    for (int i = 0; i < len; i++) {
        char c = str[i];
        if (c == '-') negative = true;
        else if (c >= '0' and c <= '9') {
            curval *= 10;
            curval += (c-48);
        }
        else {
            if (negative) {
                curval = -curval;
                negative = false;
            }
            
            switch (c) {
                case 'Y':
                    date.tm_year = curval; break;
                case 'M':
                    date.tm_mon = curval; break;
                case 'D':
                    date.tm_mday = curval; break;
                case 'h':
                    date.tm_hour = curval; break;
                case 'm':
                    date.tm_min = curval; break;
                case 's':
                    date.tm_sec = curval; break;
            }
            
            curval = 0;
        }
    }

    return E_OK;
}
