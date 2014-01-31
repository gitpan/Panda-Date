#ifndef pperl_h_included
#define pperl_h_included

#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#ifdef __cplusplus
}
#endif
#include "ppport.h"

typedef HV* HVR;
typedef AV* AVR;

#endif
