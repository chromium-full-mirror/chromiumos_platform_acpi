#!/bin/sh

# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# TODO: This is specific to eeepc. Figure out a way to generalize and
# add support for additional hotkeys.
#
# TODO(ajwong): Find a better way to talk to pulseaudio than changing to the
# chronos user and talking to pulseaudio via amixer.

USER_ID="$(/usr/bin/id -u chronos)"
MINIJAIL_FLAGS="--use-capabilities"

export PULSE_RUNTIME_PATH=/var/run/pulse

case "$3" in
  00000013)  # Toggle sound
        /sbin/minijail ${MINIJAIL_FLAGS} --uid=${USER_ID} -- \
            /usr/bin/amixer set Master toggle
        ;;
  00000014)  # Decrease volume
        /sbin/minijail ${MINIJAIL_FLAGS} --uid=${USER_ID} -- \
            /usr/bin/amixer set Master 5%-
        ;;
  00000015)  # Increase volume
        /sbin/minijail ${MINIJAIL_FLAGS} --uid=${USER_ID} -- \
            /usr/bin/amixer set Master 5%+
        ;;
esac
