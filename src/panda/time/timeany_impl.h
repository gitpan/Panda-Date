#undef PTIME_ANY_BORDER
#undef PTIME_ANY_INNER
#ifdef PTIME_AMBIGUOUS_LATER
#  define PTIME_ANY_BORDER local_lower
#  define PTIME_ANY_INNER  (inner_epoch >= outborder && outer_epoch < inborder)
#else
#  define PTIME_ANY_BORDER local_upper
#  define PTIME_ANY_INNER  (min_epoch >= outborder && min_epoch < inborder)
#endif

#undef PTIME_ANY_NORMALIZE_LEAPSEC
#undef PTIME_ANY_NORMALIZE_LEAPSEC_KISF
#undef PTIME_ANY_NORMALIZE_LEAPSEC_KIST
#ifdef PTIME_ANY_NORMALIZE
#  define PTIME_ANY_NORMALIZE_LEAPSEC(trans) \
    igmtime(local_epoch, date); \
    date->n_zone = trans.n_abbrev; \
    date->gmtoff = trans.gmt_offset; \
    date->isdst  = trans.isdst; \
    if (keep_input_sec) date->sec = input_sec;
#  define PTIME_ANY_NORMALIZE_LEAPSEC_KISF bool keep_input_sec = false
#  define PTIME_ANY_NORMALIZE_LEAPSEC_KIST keep_input_sec = true
#else
#  define PTIME_ANY_NORMALIZE_LEAPSEC(trans)
#  define PTIME_ANY_NORMALIZE_LEAPSEC_KISF
#  define PTIME_ANY_NORMALIZE_LEAPSEC_KIST
#endif

#undef PTIME_ANY_LEAPSEC_CORR
#define PTIME_ANY_LEAPSEC_CORR(trans) \
    if (local_epoch < trans.leap_lend) { \
        ptime_t norm_sec = (date->sec + OUTLIM_EPOCH_BY_86400) % 60; \
        PTIME_ANY_NORMALIZE_LEAPSEC_KISF; \
        int32_t offset = trans.offset; \
        if (input_sec >= 60 && input_sec < 60 + trans.leap_delta) { \
            local_epoch -= trans.leap_delta; \
            PTIME_ANY_NORMALIZE_LEAPSEC_KIST; \
        } \
        else if (norm_sec >= 60 - trans.leap_delta) offset += trans.leap_delta; \
        PTIME_ANY_NORMALIZE_LEAPSEC(trans); \
        return local_epoch - offset; \
    }
    
    
{
    ptime_t input_sec = date->sec;
    
    ptime_t local_epoch = itimegml(date);
    
    if (local_epoch < zone->ltrans.PTIME_ANY_BORDER) {
        __PTIME_TRANS_BINFIND(local_epoch, PTIME_ANY_BORDER);
        PTIME_ANY_LEAPSEC_CORR(zone->trans[index]);
#ifdef PTIME_ANY_NORMALIZE
        if (local_epoch >= zone->trans[index].local_end) {
            // normalize forward jump period
            igmtime(local_epoch + zone->trans[index+1].delta, date);
            date->n_zone = zone->trans[index+1].n_abbrev;
            date->gmtoff = zone->trans[index+1].gmt_offset;
            date->isdst  = zone->trans[index+1].isdst;
        }
        else {
            igmtime(local_epoch, date);
            date->n_zone = zone->trans[index].n_abbrev;
            date->gmtoff = zone->trans[index].gmt_offset;
            date->isdst  = zone->trans[index].isdst;
        }
#endif
        return local_epoch - zone->trans[index].offset;
    }
    
    PTIME_ANY_LEAPSEC_CORR(zone->ltrans);
    
    if (!zone->future.hasdst) {
#ifdef PTIME_ANY_NORMALIZE
        igmtime(local_epoch, date);
        date->n_zone = zone->future.outer.n_abbrev;
        date->gmtoff = zone->future.outer.gmt_offset;
        date->isdst  = zone->future.outer.isdst;
#endif
        return local_epoch - zone->future.outer.offset;
    }

    igmtime(local_epoch, date); // need yday and wday
    int is_leap = is_leap_year(date->year);
    ptime_t outborder   = _calc_rule_epoch(is_leap, date, zone->future.outer.end) - zone->future.outer.offset;
    ptime_t inborder    = _calc_rule_epoch(is_leap, date, zone->future.inner.end) - zone->future.inner.offset;
#ifndef PTIME_AMBIGUOUS_LATER
    ptime_t min_epoch   = local_epoch - zone->future.max_offset;
#endif
    ptime_t outer_epoch = local_epoch - zone->future.outer.offset;
    ptime_t inner_epoch = local_epoch - zone->future.inner.offset;

#ifndef PTIME_ANY_NORMALIZE
    return PTIME_ANY_INNER ? inner_epoch : outer_epoch;
#else
    if (PTIME_ANY_INNER) {
        if (zone->future.delta < 0 && inner_epoch >= inborder) {
            // normalize forward jump period for southern hemisphere
            igmtime(local_epoch - zone->future.delta, date);
            date->n_zone = zone->future.outer.n_abbrev;
            date->gmtoff = zone->future.outer.gmt_offset;
            date->isdst  = zone->future.outer.isdst;
        } else {
            date->n_zone = zone->future.inner.n_abbrev;
            date->gmtoff = zone->future.inner.gmt_offset;
            date->isdst  = zone->future.inner.isdst;
        }
        return inner_epoch;
    }
    else if (zone->future.delta > 0 && inner_epoch < outborder && outer_epoch >= outborder) {
        // normalize forward jump period for northern hemisphere
        igmtime(local_epoch + zone->future.delta, date);
        date->n_zone = zone->future.inner.n_abbrev;
        date->gmtoff = zone->future.inner.gmt_offset;
        date->isdst  = zone->future.inner.isdst;
    } else {
        date->n_zone = zone->future.outer.n_abbrev;
        date->gmtoff = zone->future.outer.gmt_offset;
        date->isdst  = zone->future.outer.isdst;
    }
    return outer_epoch;
#endif
}
