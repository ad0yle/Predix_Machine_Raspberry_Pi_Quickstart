#!/bin/sh
PROCESSOR=arm_raspbian

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

# export MBSA_LOG_DISABLED=1
export LOG_ENABLED="true"
[ "$MBSA_LOG_DISABLED" = "1" ] && export LOG_ENABLED="false" 


# uncomment for synchronous/asynchronous stop command
STOPCMD=stopsync
#STOPCMD=stop

# uncomment and modify the following line if mbs needs more than 60s for stopping
#export MBSA_STOP_TIMEOUT=60

echo "Stopping mBSA [`pwd`/../lib/runtimes/$MBSA_TARGET_PLATFORM/mbsae.core $@]..."
#../lib/runtimes/$MBSA_TARGET_PLATFORM/mbsae.core mbsa.cmd=$STOPCMD mbsa.log.file=./logs/mbsa_stop.log core.log.enable=$LOG_ENABLED $*
# GE Modified
../lib/runtimes/$MBSA_TARGET_PLATFORM/mbsae.core mbsa.cmd=$STOPCMD mbsa.log.file=../../logs/mbsa/mbsa_stop.log core.log.enable=$LOG_ENABLED $*
rc=$?
echo "mBSA exit code: $rc"
exit $rc

##########
# code 0   - mbsa stopped successfuly
# code 1   - mbsa stop failed (e.g. configuration issues)
# code 2   - mbsa already stopped (synch was unavailable upon script startup)
# code 3   - mbsa synch stop timeouted (consider increasing MBSA_STOP_TIMEOUT env. variable)
# code 99  - mbsa platform error
# code 100 - mbsa is stopping (retry until exit code=2 or exit code=1)
