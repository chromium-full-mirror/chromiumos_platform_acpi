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


# Shutdowns instead of sleeping if no one is logged in.
if ! test -f /var/run/state/logged-in; then
  logger "action_lid.sh: lid closed. Shutting down since no one is logged in"
  shutdown -h now
  exit 0
fi

logger "action_lid.sh: lid closed. Going to suspend-to-RAM state"

# On lid close:
# - locks the screen
export HOME=/home/chronos
/usr/bin/xscreensaver-command -l

# - logs the time going to suspend (no-op if no RTC).
cp /sys/class/rtc/rtc0/since_epoch /var/log/metrics/suspend-to-ram-time \
  2> /dev/null || true

# - announces the event
/usr/bin/dbus-send --type=signal --system / \
  org.chromium.Power.Manager.PowerStateChanged string:mem

# - sleeps for a bit to give the window manager time to draw the xscreensaver
#   window to the screen -- see http://crosbug.com/2250.
# TODO: Remove this hack once we have a better solution in place that adds
# some coordination between the screen locker and the window manager.
sleep 0.5

# - suspends the cryptohome device
#CRYPTOHOME=/dev/mapper/cryptohome
#/usr/bin/test -b $CRYPTOHOME && /sbin/dmsetup suspend $CRYPTOHOME

# - suspends to ram
echo -n mem > /sys/power/state

# On lid open:
# - has it such that you don't have to press a key to display lock screen
/usr/bin/xscreensaver-command -deactivate

# - announces the event
/usr/bin/dbus-send --type=signal --system / \
  org.chromium.Power.Manager.PowerStateChanged string:on &

# - sends UMA metrics on resume
/usr/bin/send_metrics_on_resume

# - resumes cryptohome device
#/usr/bin/test -b $CRYPTOHOME && /sbin/dmsetup resume $CRYPTOHOME
