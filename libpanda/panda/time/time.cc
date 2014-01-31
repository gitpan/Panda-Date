#include "time.h"

namespace panda { namespace time {

void gmtime (ptime_t epoch, dt* result) {
    igmtime(epoch, result);
}

ptime_t timegml (dt *date) {
    return itimegml(date);
}

ptime_t timegm (dt *date) {
    return itimegm(date);
}

void anytime (ptime_t epoch, dt* result, const tz* zone) {
    ianytime(epoch, result, zone);
}

void localtime (ptime_t epoch, dt* result) {
    ilocaltime(epoch, result);
}

ptime_t timeanyl (dt* date, const tz* zone) {
    return itimeanyl(date, zone);
}

ptime_t timeany (dt* date, const tz* zone) {
    return itimeany(date, zone);
}

ptime_t timelocall (dt* date) {
    return itimeanyl(date, tzlocal());
}

ptime_t timelocal (dt* date) {
    return itimeany(date, tzlocal());
}

};};
