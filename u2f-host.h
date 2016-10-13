/*
  Copyright (C) 2013-2015 Yubico AB

  This program is free software; you can redistribute it and/or modify it
  under the terms of the GNU Lesser General Public License as published by
  the Free Software Foundation; either version 2.1, or (at your option) any
  later version.

  This program is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
  General Public License for more details.

  You should have received a copy of the GNU Lesser General Public License
  along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

#ifndef U2F_HOST_H
#define U2F_HOST_H

#include <stdint.h>
#include <string.h>

#include "u2f-host-version.h"
#include "u2f-host-types.h"

#ifdef __cplusplus
extern "C"
{
#endif

/* Must be called successfully before using any other functions. */
  extern u2fh_rc u2fh_global_init (u2fh_initflags flags);
  extern void u2fh_global_done (void);

  extern const char *u2fh_strerror (int err);
  extern const char *u2fh_strerror_name (int err);

  extern u2fh_rc u2fh_devs_init (u2fh_devs ** devs);
  extern u2fh_rc u2fh_devs_discover (u2fh_devs * devs, unsigned *max_index);
  extern void u2fh_devs_done (u2fh_devs * devs);

  extern u2fh_rc u2fh_register (u2fh_devs * devs,
				const char *challenge,
				const char *origin,
				char **response, u2fh_cmdflags flags);

  extern u2fh_rc u2fh_authenticate (u2fh_devs * devs,
				    const char *challenge,
				    const char *origin,
				    char **response, u2fh_cmdflags flags);

  extern u2fh_rc u2fh_sendrecv (u2fh_devs * devs,
				unsigned index,
				uint8_t cmd,
				const unsigned char *send,
				uint16_t sendlen,
				unsigned char *recv, size_t * recvlen);

  extern u2fh_rc u2fh_get_device_description (u2fh_devs * devs,
					      unsigned index, char *out,
					      size_t * len);

  extern int u2fh_is_alive (u2fh_devs * devs, unsigned index);

#ifdef __cplusplus
}
#endif
#endif
