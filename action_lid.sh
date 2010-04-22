#!/bin/sh

# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Shutdown instead of sleeping if no one is logged in
if ! test -f /var/run/state/logged-in; then
  shutdown -h now
  exit 0
fi

# Check whether the lid is closed before proceeding
grep -q open /proc/acpi/button/lid/*/state
if [ $? = 0 ]; then
  exit 0
fi

# On lid close:
# - lock the screen
export HOME=/home/chronos
/usr/bin/xscreensaver-command -l

# - sleep for a bit to give the window manager time to draw the xscreensaver
#   window to the screen -- see http://crosbug.com/2250.
# TODO: Remove this hack once we have a better solution in place that adds
# some coordination between the screen locker and the window manager.
sleep 0.5

# - suspend the cryptohome device
#CRYPTOHOME=/dev/mapper/cryptohome
#/usr/bin/test -b $CRYPTOHOME && /sbin/dmsetup suspend $CRYPTOHOME

# - suspend to ram
echo -n mem > /sys/power/state

# On lid open:
# - has it such that you don't have to press a key to display lock screen
/usr/bin/xscreensaver-command -deactivate

# - resume cryptohome device
#/usr/bin/test -b $CRYPTOHOME && /sbin/dmsetup resume $CRYPTOHOME
