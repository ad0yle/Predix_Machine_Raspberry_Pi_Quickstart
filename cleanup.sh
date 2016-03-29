#!/bin/bash
set -e
# Cleanup Script
# Authors: GE SDLP 2015
#

source variables.sh

cf d $FRONT_END_APP_NAME -f

cf d $TEMP_APP -f

cf ds $TIMESERIES_INSTANCE_NAME -f

cf ds $ASSET_INSTANCE_NAME -f

cf ds $UAA_INSTANCE_NAME -f
