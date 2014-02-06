#pragma once

#include <panda/std.h>
#include <panda/perl.h>
#include <panda/util.h>
#include <panda/time.h>
#include <panda/date.h>

#ifdef _WIN32
#  define SYSTIMEGM(x)    _mkgmtime(x)
#  define SYSTIMELOCAL(x) mktime(x)
#else
#  define SYSTIMEGM(x)    timegm(x)
#  define SYSTIMELOCAL(x) timelocal(x)
#endif

#if IVSIZE >= 8
#  define SvMIV(x) SvIV(x)
#  define SvMUV(x) SvUV(x)
#else
#  define SvMIV(x) ((int64_t)SvNV(x))
#  define SvMUV(x) ((uint64_t)SvNV(x))
#endif

namespace panda { namespace xsdate {

using namespace panda::time;
using namespace panda::date;

static const char* DATE_CLASS    = "Panda::Date";
static const char* DATEREL_CLASS = "Panda::Date::Rel";
static const char* DATEINT_CLASS = "Panda::Date::Int";

inline tz* tzget_required (SV* zone) {
    return (zone && SvOK(zone)) ? tzget(SvPV_nolen(zone)) : tzlocal();
}

inline tz* tzget_optional (SV* zone) {
    return zone ? (SvOK(zone) ? tzget(SvPV_nolen(zone)) : tzlocal()) : NULL;
}

inline void daterel_chkro (DateRel* THIS) {
    if (THIS->isConst()) croak("Panda::Date::Rel: cannot change this object - it's read only");
}

};};
