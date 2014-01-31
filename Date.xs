#include "Date.h"
#include "util.h"

using namespace panda::xsdate;
using namespace panda::time;
using namespace panda::date;

MODULE = Panda::Date                PACKAGE = Panda::Date
PROTOTYPES: DISABLE

INCLUDE: time.xsi
INCLUDE: Date.xsi
INCLUDE: DateRel.xsi
INCLUDE: DateInt.xsi
INCLUDE: Storable.xsi
INCLUDE: test.xsi
