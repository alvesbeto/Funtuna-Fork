#ifndef FUNTUNA_IO_COMPAT_H
#define FUNTUNA_IO_COMPAT_H

/* PS2SDK newlib: fio/fileXio types and mode flags for uLaunchELF-derived code. */
#ifndef NEWLIB_PORT_AWARE
#define NEWLIB_PORT_AWARE 1
#endif

#include <strings.h>
#include <io_common.h>
#include <iox_stat.h>

typedef io_dirent_t fio_dirent_t;

#ifndef stricmp
#define stricmp strcasecmp
#endif

#endif
