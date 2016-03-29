#!/bin/sh
PROCESSOR=arm_raspbian

# mbsa trap cleanup funtion
cleanup()
{
  echo
  echo "mbsae.core terminated unexpectedly..."
  sleep 1

  # uncomment to ensure mbsae.core threads are all killed
  #echo " - Killing mbsae.core ..."; killall -9 mbsae.core

  # uncomment to ensure jvm is killed after mbsa termination
  #echo " - Killing JVM..."; killall -9 j9

  # Cleanup default sync file 'mbsa_sync_core.snc'
  echo " - Clenaup sync: $MBSA_DIR/mbsa_sync_core.snc"
  rm -f "$MBSA_DIR/mbsa_sync_core.snc"

  echo
  echo
}


# dirname could be missing, so prevent changing dir to $HOME
MBSA_DIR=`dirname "$0" 2>/dev/null`
[ -n "$MBSA_DIR" ] && cd "$MBSA_DIR"


### Do not overrride TARGET_PLATFORM if defined
if [ -z "$TARGET_PLATFORM" ]; then

	export MBSA_PROCESSOR="$PROCESSOR"
	if [ -z "$MBSA_PROCESSOR" ]; then
		# added cpu detection in sync with server scripts (only accept "x86_64", as we may have i386, i686, etc.)
		MBSA_ARCH=`uname -m 2>/dev/null`
		case $MBSA_ARCH in
			x86|i386|i486|i586|i686)
				export MBSA_PROCESSOR="x86"
				;;
			x86_64|ia64)
				export MBSA_PROCESSOR="x86_64"
				;;
			*)
				# detection failed -> fallback to "x86"
				echo "WARNING: Unsupported processor ($MBSA_ARCH)"
				export MBSA_PROCESSOR="x86"
		esac
	fi

	if [ "`uname -s`" = "Darwin" ]; then
		export MBSA_TARGET_PLATFORM="macosx/$MBSA_PROCESSOR"
	else
		# replace "x86" PROCESSOR to supported "i386" runtimes
		[ "$MBSA_PROCESSOR" = "x86" ] && export MBSA_PROCESSOR="i386"
		export MBSA_TARGET_PLATFORM="linux/$MBSA_PROCESSOR"
		if [ ! -d "`pwd`/../lib/runtimes/$MBSA_TARGET_PLATFORM" ]; then
		# add support for standard 8.0 board extension platform definitions
			export MBSA_TARGET_PLATFORM="linux/linux_$MBSA_PROCESSOR"
		fi
	fi

else
	export MBSA_TARGET_PLATFORM="$TARGET_PLATFORM"
	### Special case: if TARGET_PLATFORM="linux/x86" -> "linux/i386"
	[ "$MBSA_TARGET_PLATFORM" = "linux/x86" ] && export MBSA_TARGET_PLATFORM="linux/i386"
fi

# check TARGET_PLATFORM consistency
if [ ! -d "`pwd`/../lib/runtimes/$MBSA_TARGET_PLATFORM" ]; then
	echo "Target platform \"$MBSA_TARGET_PLATFORM\" is missing in mBSA runtimes: `pwd`/../lib/runtimes/"
	exit 99
fi

# setup OS dependent LD_LIBRARY_PATH && configs path
if [ "`uname -s`" = "Darwin" ]; then
    # macosx support
	export MBSA_CONFIG="./configs/macosx"
    export DYLD_LIBRARY_PATH="`pwd`/../lib/runtimes/$MBSA_TARGET_PLATFORM:`pwd`/../lib/runtimes/$MBSA_TARGET_PLATFORM/plugins:$DYLD_LIBRARY_PATH"
    echo "### DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH"
else
	export MBSA_CONFIG="./configs/linux"
	export LD_LIBRARY_PATH="`pwd`/../lib/runtimes/$MBSA_TARGET_PLATFORM:`pwd`/../lib/runtimes/$MBSA_TARGET_PLATFORM/plugins:$LD_LIBRARY_PATH"
fi


## try to parse ip from ifconfig (Change eth0 to another interface if required)
#IP=`ifconfig eth0 | grep 'inet addr:' | cut -f 2 -d: | cut -d' ' -f 1`
#[ -n "$IP" ] && export MBSA_HOST_IP=$IP

[ -n "$MBSA_HOST_IP" ] && echo "Using MBSA_HOST_IP: $MBSA_HOST_IP"

## Uncomment for auto updating of main mbsa TargetID, when external ip is changed
## MBSA_AUTO_IP Format is "#" for using hostname to resolve external ip, or filename e.g. "/tmp/.mbsa.host.ip" to read IP when changed
# export MBSA_AUTO_IP=#

if [ "$MBSA_AUTO_IP" = "#" ]; then 
  echo "Using MBSA_AUTO_IP: from hostname (`hostname`)"
else
  [ -n "$MBSA_AUTO_IP" ] && echo "Using MBSA_AUTO_IP: from file: $MBSA_AUTO_IP"
fi

## mBSA modules print on console enablers
# export LOG_MBSMANAGER=1
# export LOG_NRUNNER=1 NRUNNER_DEBUG=3

## Global mBSA log disable
# export MBSA_LOG_DISABLED=1

## Uncomment to override default mBSA crash log dir "."
#export MBSA_CRASHDIR=/tmp
# GE Modified
export MBSA_CRASHDIR=../logs/mbsa

export LOG_ENABLED="true"
[ "$MBSA_LOG_DISABLED" = "1" ] && export LOG_ENABLED="false" 

# mBSA Log configuration
export LOG_CFG="core.log.maxsize=250 core.log.parts=2 core.log.maxcount=10 core.log.enable=$LOG_ENABLED"
if [ "`uname -s`" = "Darwin" ]; then
  # Macosx with more logging as still unstable
  export LOG_CFG="core.log.maxsize=0 core.log.level=1000 core.log.parts=2 core.log.maxcount=0 core.log.enable=$LOG_ENABLED"
fi

# uncomment to enable cleanup after mbsa crash
#trap cleanup SIGINT SIGTERM SIGABRT SIGKILL SIGSEGV SIGQUIT SIGILL SIGBUS

echo "Starting mBSA [`pwd`/../lib/runtimes/$MBSA_TARGET_PLATFORM/mbsae.core $@]..."
#../lib/runtimes/$MBSA_TARGET_PLATFORM/mbsae.core mbsa.cmd=start core.plugins.dir=../lib/runtimes/$MBSA_TARGET_PLATFORM/plugins mbsa.log.file=./logs/mbsa_start.log core.log.file=./logs/core.log core.prs.file=$MBSA_CONFIG/mbsal.core.prs $LOG_CFG $*
# GE Modified
../lib/runtimes/$MBSA_TARGET_PLATFORM/mbsae.core mbsa.cmd=start core.plugins.dir=../lib/runtimes/$MBSA_TARGET_PLATFORM/plugins mbsa.log.file=../../logs/mbsa/mbsa_start.log core.log.file=../../logs/mbsa/core.log core.prs.file=$MBSA_CONFIG/mbsal.core.prs $LOG_CFG $*
rc=$?
echo "mBSA exit code: $rc"
exit $rc

##########
# code 0  - mbsa started and exitted normally
# code 1  - mbsa start failed (e.g. configuration issues)
# code 2  - mbsa already started
# code 99 - mbsa platform error
