#pragma once

#ifndef likely
#define likely(x)   __builtin_expect((x),1)
#define unlikely(x) __builtin_expect((x),0)
#endif

#define PTIME_GMT_ZONE     "UTC\0xxx"
#define PTIME_GMT_FALLBACK "UTC0"

#if defined(__FreeBSD__) || defined(__NetBSD__) || defined(__OpenBSD__) || defined(__bsdi__) || defined(__DragonFly__)
#  include <sys/endian.h>
#  define PTIME_OSTYPE_UNIX
#  define PTIME_ZONEDIR "/usr/share/zoneinfo"

#elif defined __linux__
#  ifndef _BSD_SOURCE
#    define _BSD_SOURCE
#  endif
#  include <endian.h>
#  define PTIME_OSTYPE_UNIX
#  define PTIME_ZONEDIR "/usr/share/zoneinfo"

#elif defined __APPLE__
#  include <libkern/OSByteOrder.h>
#  define be64toh(x) OSSwapBigToHostInt64(x)
#  define htobe64(x) OSSwapHostToBigInt64(x)
#  define be32toh(x) OSSwapBigToHostInt32(x)
#  define PTIME_OSTYPE_UNIX
#  define PTIME_ZONEDIR "/usr/share/zoneinfo"

#elif defined __VMS
#  include <endian.h>
#  define PTIME_OSTYPE_VMS
#  define PTIME_ZONEDIR "/usr/share/zoneinfo"

#elif defined _WIN32
#  define PTIME_OSTYPE_WIN
#  define bzero(b,len) (memset((b), '\0', (len)), (void) 0)

#else
#error "Current operating system is not supported" 
#endif

#ifdef TZDIR
#  undef  PTIME_ZONEDIR
#  define PTIME_ZONEDIR TZDIR
#endif

#ifndef PTIME_ZONEDIR
#  define PTIME_ZONEDIR  NULL
#endif
