#pragma once

#ifndef likely
#define likely(x)   __builtin_expect((x),1)
#define unlikely(x) __builtin_expect((x),0)
#endif

#define PTIME_GMT_ZONE     "UTC\0xxx"
#define PTIME_GMT_FALLBACK "UTC0"

#if defined(__FreeBSD__) || defined(__NetBSD__) || defined(__bsdi__) || defined(__DragonFly__)
#  include <sys/endian.h>
#  define PTIME_OSTYPE_UNIX
#  define PTIME_ZONEDIR "/usr/share/zoneinfo"
#  define PTIME_BE64TOH(x) be64toh(x)
#  define PTIME_BE32TOH(x) be32toh(x)
#  define PTIME_HTOBE64(x) htobe64(x)

#elif defined __linux__
#  ifndef _BSD_SOURCE
#    define _BSD_SOURCE
#  endif
#  include <endian.h>
#  define PTIME_OSTYPE_UNIX
#  define PTIME_ZONEDIR "/usr/share/zoneinfo"
#  define PTIME_BE64TOH(x) be64toh(x)
#  define PTIME_BE32TOH(x) be32toh(x)
#  define PTIME_HTOBE64(x) htobe64(x)

#elif defined __APPLE__
#  include <libkern/OSByteOrder.h>
#  define PTIME_OSTYPE_UNIX
#  define PTIME_ZONEDIR "/usr/share/zoneinfo"
#  define PTIME_BE64TOH(x) OSSwapBigToHostInt64(x)
#  define PTIME_BE32TOH(x) OSSwapBigToHostInt32(x)
#  define PTIME_HTOBE64(x) OSSwapHostToBigInt64(x)

#elif defined __VMS
#  include <endian.h>
#  define PTIME_OSTYPE_VMS
#  define PTIME_ZONEDIR "/usr/share/zoneinfo"
#  define PTIME_BE64TOH(x) be64toh(x)
#  define PTIME_BE32TOH(x) be32toh(x)
#  define PTIME_HTOBE64(x) htobe64(x)

#elif defined _WIN32
#  include <Winsock2.h> 
#  define PTIME_OSTYPE_WIN
#  define bzero(b,len) (memset((b), '\0', (len)), (void) 0)
#  define PTIME_AM_I_LITTLE (((union { unsigned x; unsigned char c; }){1}).c)
#  define PTIME_BSWAP64(x) (((uint64_t)ntohl(x)) << 32 | ntohl(x>>32))
#  define PTIME_HSWAP64(x) (((uint64_t)htonl(x)) << 32 | htonl(x>>32))
#  define PTIME_BE64TOH(x) (PTIME_AM_I_LITTLE ? (PTIME_BSWAP64(x)) : (x))
#  define PTIME_BE32TOH(x) ntohl(x)
#  define PTIME_HTOBE64(x) (PTIME_AM_I_LITTLE ? (PTIME_HSWAP64(x)) : (x))

#elif defined __OpenBSD__
#  include <sys/types.h>
#  define PTIME_OSTYPE_UNIX
#  define PTIME_ZONEDIR "/usr/share/zoneinfo"
#  define PTIME_BE64TOH(x) betoh64(x)
#  define PTIME_BE32TOH(x) betoh32(x)
#  define PTIME_HTOBE64(x) htobe64(x)

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
