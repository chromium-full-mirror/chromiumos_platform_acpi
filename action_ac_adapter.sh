#!/bin/sh

# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

test -f /usr/sbin/laptop_mode || exit 0

/usr/sbin/laptop_mode auto
