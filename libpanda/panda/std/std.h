#ifndef pstd_h_included
#define pstd_h_included

#ifndef likely
#define likely(x)       __builtin_expect((x),1)
#define unlikely(x)     __builtin_expect((x),0)
#endif

namespace panda { namespace std {

}};

#endif
