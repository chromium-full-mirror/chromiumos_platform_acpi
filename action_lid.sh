#!/bin/sh

# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

logger "action_lid.sh: " `cat /proc/acpi/button/lid/*/state`

grep -q "closed" /proc/acpi/button/lid/*/state
if [ $? != 0 ]; then
  logger "action_lid.sh: lid is not closed. Bailing out."
  exit 0
fi

logger "action_lid.sh: lid closed. Requesting suspend."
/usr/bin/dbus-send --type=signal --system / \
  org.chromium.PowerManager.RequestSuspend
