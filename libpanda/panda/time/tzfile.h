#pragma once

static const char* FTZ_MAGIC      = "TZif";
static const int   FTZ_MAX_TIMES  = 1200;
static const int   FTZ_MAX_TYPES  = 256;
static const int   FTZ_MAX_CHARS  = 50;  /* Maximum number of abbreviation characters */
static const int   FTZ_MAX_LEAPS  = 50;  /* Maximum number of leap second corrections */

struct ftz_head {
    char     tzh_magic[4];     /* TZ_MAGIC */
    char     tzh_version[1];   /* '\0' or '2' as of 2005 */
    char     tzh_reserved[15]; /* reserved--must be zero */
    uint32_t tzh_ttisgmtcnt;   /* coded number of trans. time flags */
    uint32_t tzh_ttisstdcnt;   /* coded number of trans. time flags */
    uint32_t tzh_leapcnt;      /* coded number of leap seconds */
    uint32_t tzh_timecnt;      /* coded number of transition times */
    uint32_t tzh_typecnt;      /* coded number of local time types */
    uint32_t tzh_charcnt;      /* coded number of abbr. chars */
};

typedef int32_t ftz_transtimeV1;
typedef int64_t ftz_transtimeV2;
typedef uint8_t ftz_ilocaltype;
typedef uint8_t ftz_abbrev_offset;
typedef uint8_t ftz_isstd;
typedef uint8_t ftz_isgmt;

const int ftz_localtype_size = sizeof(int32_t) + sizeof(uint8_t) + sizeof(ftz_abbrev_offset);
struct ftz_localtype {
    int32_t           offset;
    uint8_t           isdst;
    ftz_abbrev_offset abbrev_offset;
};

const int ftz_leapsecV1_size = sizeof(ftz_transtimeV1) + sizeof(uint32_t);
struct ftz_leapsecV1 {
    ftz_transtimeV1 time;
    uint32_t        correction;
};

const int ftz_leapsecV2_size = sizeof(ftz_transtimeV2) + sizeof(uint32_t);
struct ftz_leapsecV2 {
    ftz_transtimeV2 time;
    uint32_t        correction;
};

/*
** . . .followed by. . .
**
**  tzh_timecnt (char [4])s     coded transition times a la time(2)
**  tzh_timecnt (unsigned char)s    types of local time starting at above
**  tzh_typecnt repetitions of
**      one (char [4])      coded UTC offset in seconds
**      one (unsigned char) used to set tm_isdst
**      one (unsigned char) that's an abbreviation list index
**  tzh_charcnt (char)s     '\0'-terminated zone abbreviations
**  tzh_leapcnt repetitions of
**      one (char [4])      coded leap second transition times
**      one (char [4])      total correction after above
**  tzh_ttisstdcnt (char)s      indexed by type; if TRUE, transition
**                  time is standard time, if FALSE,
**                  transition time is wall clock time
**                  if absent, transition times are
**                  assumed to be wall clock time
**  tzh_ttisgmtcnt (char)s      indexed by type; if TRUE, transition
**                  time is UTC, if FALSE,
**                  transition time is local time
**                  if absent, transition times are
**                  assumed to be local time
*/

/*
** If tzh_version is '2' or greater, the above is followed by a second instance
** of tzhead and a second instance of the data in which each coded transition
** time uses 8 rather than 4 chars,
** then a POSIX-TZ-environment-variable-style string for use in handling
** instants after the last transition time stored in the file
** (with nothing between the newlines if there is no POSIX representation for
** such instants).
*/
