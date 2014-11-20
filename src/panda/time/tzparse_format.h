#undef PTIME_TZPARSE_HEADERFUNC
#undef PTIME_TZPARSE_BODYFUNC
#undef PTIME_TZPARSE_TRANSTIME_TYPE
#undef PTIME_TZPARSE_LEAPSEC_TYPE
#undef PTIME_TZPARSE_LEAPSEC_SIZE
#undef PTIME_TZPARSE_NTOH_DYN

#ifdef PTIME_TZPARSE_V2
#  define PTIME_TZPARSE_HEADERFUNC     tzparse_headerV2
#  define PTIME_TZPARSE_BODYFUNC       tzparse_bodyV2
#  define PTIME_TZPARSE_TRANSTIME_TYPE ftz_transtimeV2
#  define PTIME_TZPARSE_LEAPSEC_TYPE   ftz_leapsecV2
#  define PTIME_TZPARSE_LEAPSEC_SIZE   ftz_leapsecV2_size
#  define PTIME_TZPARSE_NTOH_DYN(val)  ((int64_t)PTIME_BE64TOH(val))
#else
#  define PTIME_TZPARSE_HEADERFUNC     tzparse_headerV1
#  define PTIME_TZPARSE_BODYFUNC       tzparse_bodyV1
#  define PTIME_TZPARSE_TRANSTIME_TYPE ftz_transtimeV1
#  define PTIME_TZPARSE_LEAPSEC_TYPE   ftz_leapsecV1
#  define PTIME_TZPARSE_LEAPSEC_SIZE   ftz_leapsecV1_size
#  define PTIME_TZPARSE_NTOH_DYN(val)  ((int32_t)PTIME_BE32TOH(val))
#endif

#ifndef PTIME_TZPARSE_TRANSCMP
# define PTIME_TZPARSE_TRANSCMP
static int trans_cmp (const void* _a, const void* _b) {
    tztrans* a = (tztrans*) _a;
    tztrans* b = (tztrans*) _b;
    if (a->start < b->start) return -1;
    else if (a->start == b->start) return 0;
    else return 1;
}
#endif

static inline int PTIME_TZPARSE_HEADERFUNC (char** ptr, ftz_head& head, int* version) {
    memcpy(&head, *ptr, 44);
    *ptr += 44;
    
    if (strncmp(head.tzh_magic, FTZ_MAGIC, strlen(FTZ_MAGIC)-1) != 0) {
        //fprintf(stderr, "ptime: BAD FILE MAGIC\n", head.tzh_magic);
        return -1;
    }
    
    char tzh_version_str[2];
    tzh_version_str[0] = head.tzh_version[0];
    tzh_version_str[1] = '\0';
    *version = (int) strtol(tzh_version_str, NULL, 10);
    
    head.tzh_ttisgmtcnt = PTIME_BE32TOH(head.tzh_ttisgmtcnt);
    head.tzh_ttisstdcnt = PTIME_BE32TOH(head.tzh_ttisstdcnt);
    head.tzh_leapcnt    = PTIME_BE32TOH(head.tzh_leapcnt);
    head.tzh_timecnt    = PTIME_BE32TOH(head.tzh_timecnt);
    head.tzh_typecnt    = PTIME_BE32TOH(head.tzh_typecnt);
    head.tzh_charcnt    = PTIME_BE32TOH(head.tzh_charcnt);
    
    if (head.tzh_timecnt > FTZ_MAX_TIMES) {
        //fprintf(stderr, "ptime: tzh_timecnt %d is greater than max supported %d\n", head.tzh_timecnt, FTZ_MAX_TIMES);
        return -1;
    }
    
    if (head.tzh_typecnt > FTZ_MAX_TYPES) {
        //fprintf(stderr, "ptime: tzh_typecnt %d is greater than max supported %d\n", head.tzh_typecnt, FTZ_MAX_TYPES);
        return -1;
    }
    
    if (head.tzh_charcnt > FTZ_MAX_CHARS) {
        //fprintf(stderr, "ptime: tzh_charcnt %d is greater than max supported %d\n", head.tzh_charcnt, FTZ_MAX_CHARS);
        return -1;
    }
    
    if (head.tzh_leapcnt > FTZ_MAX_LEAPS) {
        //fprintf(stderr, "ptime: tzh_leapcnt %d is greater than max supported %d\n", head.tzh_leapcnt, FTZ_MAX_LEAPS);
        return -1;
    }

    int to_skip = head.tzh_timecnt*sizeof(PTIME_TZPARSE_TRANSTIME_TYPE) + // transition times
                  head.tzh_timecnt*sizeof(ftz_ilocaltype) +               // types of local time starting at above
                  head.tzh_typecnt*ftz_localtype_size +                   // local times
                  head.tzh_charcnt +                                      // abbrevs
                  head.tzh_leapcnt*PTIME_TZPARSE_LEAPSEC_SIZE +           // leap seconds
                  head.tzh_ttisstdcnt*sizeof(ftz_isstd) +
                  head.tzh_ttisgmtcnt*sizeof(ftz_isgmt);

    return to_skip;
}

static inline bool PTIME_TZPARSE_BODYFUNC (char* ptr, ftz_head& head, tz* zone) {
    PTIME_TZPARSE_TRANSTIME_TYPE* transitions = (PTIME_TZPARSE_TRANSTIME_TYPE*) ptr;
    ptr += head.tzh_timecnt * sizeof(PTIME_TZPARSE_TRANSTIME_TYPE);

    ftz_ilocaltype* ilocaltypes = (ftz_ilocaltype*) ptr;
    ptr += head.tzh_timecnt * sizeof(ftz_ilocaltype);

    ftz_localtype localtypes[FTZ_MAX_TYPES];
    for (uint32_t i = 0; i < head.tzh_typecnt; i++) {
        memcpy(&localtypes[i], ptr, ftz_localtype_size);
        localtypes[i].offset = PTIME_BE32TOH(localtypes[i].offset);
        ptr += ftz_localtype_size;
    }

    char* abbrevs = ptr;
    ptr += head.tzh_charcnt * sizeof(char);

    zone->leaps_cnt = head.tzh_leapcnt;
    //zone->leaps = zone->leaps_cnt > 0 ? (tzleap*) malloc(zone->leaps_cnt * sizeof(tzleap)) : NULL;
    zone->leaps = zone->leaps_cnt > 0 ? new tzleap[zone->leaps_cnt] : NULL;
    for (uint32_t i = 0; i < head.tzh_leapcnt; i++) {
        PTIME_TZPARSE_LEAPSEC_TYPE leapsec;
        bzero(&leapsec, sizeof(leapsec));
        memcpy(&leapsec, ptr, PTIME_TZPARSE_LEAPSEC_SIZE);
        zone->leaps[i].time       = (ptime_t) PTIME_TZPARSE_NTOH_DYN(leapsec.time);
        zone->leaps[i].correction = PTIME_BE32TOH(leapsec.correction);
        ptr += PTIME_TZPARSE_LEAPSEC_SIZE;
    }

    //ftz_isstd* isstds = (ftz_isstd*) ptr;
    ptr += head.tzh_ttisstdcnt * sizeof(ftz_isstd);

    //ftz_isgmt* isgmts = (ftz_isgmt*) ptr;
    ptr += head.tzh_ttisgmtcnt * sizeof(ftz_isgmt);
    
    // find past localtype - first localtype if it's not used in transitions, otherwise it's first std time localtype
    int past_lt_index = 0;
    for (uint32_t i = 0; i < head.tzh_timecnt; ++i) {
        if (ilocaltypes[i] != 0) continue;
        past_lt_index = -1;
        break;
    }
    if (past_lt_index < 0) for (uint32_t i = 0; i < head.tzh_typecnt; ++i) {
        if (localtypes[i].isdst) continue;
        past_lt_index = i;
        break;
    }
    if (past_lt_index < 0) past_lt_index = 0;
    
    zone->trans_cnt = head.tzh_timecnt + 1 + zone->leaps_cnt; // +1 for 'past'
    size_t trans_size = zone->trans_cnt * sizeof(tztrans);
    //zone->trans = (tztrans*) malloc(trans_size);
    zone->trans = new tztrans[trans_size];
    bzero(zone->trans, trans_size);
    
    zone->trans[0].start       = EPOCH_NEGINF;
    zone->trans[0].local_start = EPOCH_NEGINF;
    zone->trans[0].local_lower = EPOCH_NEGINF;
    zone->trans[0].local_upper = EPOCH_NEGINF;
    zone->trans[0].offset      = localtypes[past_lt_index].offset;
    zone->trans[0].gmt_offset  = localtypes[past_lt_index].offset;
    zone->trans[0].delta       = 0;
    zone->trans[0].isdst       = localtypes[past_lt_index].isdst;
    zone->trans[0].leap_corr   = 0;
    zone->trans[0].leap_delta  = 0;
    zone->trans[0].leap_end    = EPOCH_NEGINF;
    zone->trans[0].leap_lend   = EPOCH_NEGINF;
    char* past_abbrev          = abbrevs + localtypes[past_lt_index].abbrev_offset;
    if (strlen(past_abbrev) > ZONE_ABBR_MAX) {
        //fprintf(stderr, "ptime: past abbrev is too long (%d), max is %d\n", strlen(past_abbrev), ZONE_ABBR_MAX);
        zone->clear();
        return false;
    }
    strcpy(zone->trans[0].abbrev, past_abbrev);

    for (uint32_t i = 0; i < head.tzh_timecnt; ++i) {
        ftz_localtype localtype = localtypes[ilocaltypes[i]];
        tztrans* this_trans     = &zone->trans[i+1];
        this_trans->start       = (ptime_t) PTIME_TZPARSE_NTOH_DYN(transitions[i]);
        this_trans->gmt_offset  = localtype.offset;
        this_trans->isdst       = localtype.isdst;
        char* abbrev            = abbrevs + localtype.abbrev_offset;
        if (strlen(abbrev) > ZONE_ABBR_MAX) {
            //fprintf(stderr, "ptime: locatype's #%d abbrev is too long (%d), max is %d\n", ilocaltypes[i], strlen(abbrev), ZONE_ABBR_MAX);
            zone->clear();
            return false;
        }
        strcpy(this_trans->abbrev, abbrev);
    }
    
    for (uint32_t i = 0; i < zone->leaps_cnt; i++) {
        tztrans* this_trans = &zone->trans[head.tzh_timecnt+i+1];
        this_trans->start     = zone->leaps[i].time;
        this_trans->leap_corr = zone->leaps[i].correction;
    }
    
    qsort(zone->trans, zone->trans_cnt, sizeof(tztrans), trans_cmp);
    
    for (uint32_t i = 1; i < zone->trans_cnt; ++i) {
        tztrans* this_trans = &zone->trans[i];
        tztrans* prev_trans = &zone->trans[i-1];
        
        if (this_trans->leap_corr != 0) {
            this_trans->leap_delta = this_trans->leap_corr - prev_trans->leap_corr;
            this_trans->gmt_offset = prev_trans->gmt_offset;
            this_trans->isdst      = prev_trans->isdst;
            strcpy(this_trans->abbrev, prev_trans->abbrev);
        } else {
            this_trans->leap_delta = 0;
            this_trans->leap_corr  = prev_trans->leap_corr;
        }
        
        this_trans->offset      = this_trans->gmt_offset - this_trans->leap_corr;
        this_trans->delta       = this_trans->offset - prev_trans->offset;
        this_trans->local_start = this_trans->start + this_trans->offset;
        prev_trans->local_end   = this_trans->start + prev_trans->offset;
        this_trans->local_lower = this_trans->local_start;
        this_trans->local_upper = std::max(this_trans->local_start, prev_trans->local_end);
        this_trans->leap_end    = this_trans->start + this_trans->leap_delta;
        this_trans->leap_lend   = this_trans->local_start + 2*this_trans->leap_delta;
    }

    char* posixstr = ptr+1; // ptr+1 because POSIX rule begins and ends with '\n'
    char* posixend = strchr(posixstr, '\n');
    
#ifdef PTIME_TZPARSE_V2
    if (posixend == NULL) {
        //fprintf(stderr, "ptime: cannot locate terminating newline character for posix string\n");
        zone->clear();
        return false;
    }
    *posixend = '\0';
#else
    posixend = posixstr;
#endif

    zone->ltrans = zone->trans[zone->trans_cnt-1];

    if (posixend - posixstr == 0) { // no posix string, using last transition
        zone->future.hasdst           = 0;
        zone->future.outer.gmt_offset = zone->ltrans.gmt_offset;
        zone->future.outer.isdst      = zone->ltrans.isdst;
        strcpy(zone->future.outer.abbrev, zone->ltrans.abbrev);
    }
    else if (!tzparse_rule(posixstr, &zone->future)) {
        //fprintf(stderr, "ptime: tzparse_rule failed\n");
        zone->clear();
        return false;
    }

    zone->future.outer.offset = zone->future.outer.gmt_offset - zone->ltrans.leap_corr;
    if (zone->future.hasdst) {
        zone->future.inner.offset = zone->future.inner.gmt_offset - zone->ltrans.leap_corr;
        zone->future.delta        = zone->future.inner.offset - zone->future.outer.offset;
        zone->future.max_offset   = std::max(zone->future.outer.offset, zone->future.inner.offset);
    }
    
    return true;
}
