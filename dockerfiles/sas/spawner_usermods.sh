#!/bin/sh -p
#
# spawner_usermods.sh
#
# This script extends spawner.sh  Add local environment variables
# to this file so they will be preserved.
#

# These options can be extended as needed.

# The following section pertains to establishing JREOPTIONS for use by the
# Spawner. These options are not enabled by default but are present here to
# allow for customer activation.

# JREOPTIONS will be processed and passed directly to the Object Spawner if active
JREOPTIONS=

# The following options are passed to the Object Spawner. Note, they must be
# valid options.
USERMODS="$JREOPTIONS -allowxcmd"