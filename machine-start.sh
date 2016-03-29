#!/bin/bash

# Predix Dev Bootstrap Machine River start script
# Authors: GE SDLP 2015
#
# This script will start up Predix Machine and begin to ingest data fed in by Machine Server to Time Series

cd PredixMachine_16.1.0/machine/bin/predix/
./predixmachine clean
