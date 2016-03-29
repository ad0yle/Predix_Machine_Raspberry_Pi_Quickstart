#!/bin/sh

# check for required variables from server_common script
[ -z "$MBS_ROOT" ] && echo '[WARNING] MBS_ROOT variable is not set!'

# setup mBSA root (relative to fwk MBS_ROOT variable)
#  export MBSA_ROOT=$MBS_ROOT
# ###[IM]### export MBSA_ROOT=$MBS_ROOT/../mbsa

export MBSA_ROOT="$MBS_ROOT/../mbsa"

# disable portinglayer debug inheritance for fw core
#export PL_DEBUG=-1

### Do not overrride TARGET_PLATFORM if defined
if [ -z "$MBSA_TARGET_PLATFORM" ]; then
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
		fi

	else
		export MBSA_TARGET_PLATFORM="$TARGET_PLATFORM"
		### Special case: if TARGET_PLATFORM="linux/x86" -> "linux/i386"
		[ "$MBSA_TARGET_PLATFORM" = "linux/x86" ] && export MBSA_TARGET_PLATFORM="linux/i386"
	fi
fi

if [ "`uname -s`" = "Darwin" ]; then
    # macosx support
	export MBSA_CONFIG="$MBSA_ROOT/bin/java/configs/macosx"
    export DYLD_LIBRARY_PATH="$MBSA_ROOT/lib/runtimes/$MBSA_TARGET_PLATFORM:$MBSA_ROOT/lib/runtimes/$MBSA_TARGET_PLATFORM/plugins:$DYLD_LIBRARY_PATH"
    echo "### DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH"
else
	export MBSA_CONFIG="$MBSA_ROOT/bin/java/configs/linux"
    export LD_LIBRARY_PATH="$MBSA_ROOT/lib/runtimes/$MBSA_TARGET_PLATFORM:$MBSA_ROOT/lib/runtimes/$MBSA_TARGET_PLATFORM/plugins:$LD_LIBRARY_PATH"
fi
# setup LD_LIBRARY_PATH
export MBS_NATIVE_PATH="$MBS_NATIVE_PATH:$MBSA_ROOT/lib/runtimes/$MBSA_TARGET_PLATFORM:$MBSA_ROOT/lib/runtimes/$MBSA_TARGET_PLATFORM/plugins"


# avoid setting "::" in MBS_SERVER_JAR, which causes warnings
if [ -n "$MBS_SERVER_JAR" ]; then 
  export MBS_SERVER_JAR="$MBS_SERVER_JAR:$MBSA_ROOT/lib/mbsa.jar"
else
  export MBS_SERVER_JAR="$MBSA_ROOT/lib/mbsa.jar"
fi


export LOG_ENABLED="true"
[ "$MBSA_LOG_DISABLED" = "1" ] && export LOG_ENABLED="false" 

# mBSA Core setup
export FEATURES="$FEATURES -Dmbsa.lib.core.prs=$MBSA_CONFIG/mbsal.core.prs -Dmbsa.lib.core.plugins.dir=$MBSA_ROOT/lib/runtimes/$MBSA_TARGET_PLATFORM/plugins"

# Uncomment to enable mBSA FaultManager support
export FEATURES="$FEATURES -Dmbs.fm.class=com.prosyst.mbs.impl.framework.module.fm.MBSAFaultManagerImpl"

# mBSA console debug/stacktraces
#export FEATURES="$FEATURES -Dmbsa.debug=true -Dmbsa.events.debug=true -Dmbsa.stacktrace=true"

# Set mBSA java core log configuration
#export FEATURES="$FEATURES -Dmbsa.lib.core.log=$MBSA_ROOT/bin/logs/fwcore/mbsaj.core.log -Dmbsa.lib.core.log.parts=2 -Dmbsa.lib.core.log.maxsize=250 -Dmbsa.lib.core.log.maxcount=10 -Dmbsa.lib.core.log.enable=$LOG_ENABLED"
# GE Modified
export FEATURES="$FEATURES -Dmbsa.lib.core.log=$MBSA_ROOT/../logs/mbsa/fwcore/mbsaj.core.log -Dmbsa.lib.core.log.parts=2 -Dmbsa.lib.core.log.maxsize=250 -Dmbsa.lib.core.log.maxcount=10 -Dmbsa.lib.core.log.enable=$LOG_ENABLED"

# Uncomment to force overriding of main mBSA TargetInfo address to localhost
export FEATURES="$FEATURES -Dmbsa.lib.tm.mbsa.override=127.0.0.1"

# mBS watchdog setup (ping timeout should be "mbs.manager.ping.timeout" / 2). mbs.mbsa.commsErrors (if > 0, mbs will exit after specified comms send errors)
export FEATURES="$FEATURES -Dmbs.comms=comms3 -Dmbs.mbsa.ping.timeout=30000 -Dmbs.mbsa.commsErrors=3"

# mBS NRuntime setup (should match mBSA nrunner plugin config)
export FEATURES="$FEATURES -Drunner.pipe.in=/tmp/.runner.ipc_i -Drunner.pipe.out=/tmp/.runner.ipc_o"

# Update Manager related configuration
if [ -d "$MBSA_ROOT/../update_storage" ]; then
  export FEATURES="$FEATURES -Dmbs.um.storage=$MBSA_ROOT/../update_storage"
fi
export FEATURES="$FEATURES -Dmbs.um.osUpdate=false"

# Prevent Framweork shutdown hook for SIGTERM
export FEATURES="$FEATURES -Dmbs.addShutdownHook=false"

echo
echo "MBS_CUR_DIR     : \"`pwd`\""
echo "MBS_NATIVE_PATH : \"$MBS_NATIVE_PATH\""
echo "MBSA_ROOT       : \"$MBSA_ROOT\""
echo "Update Storage  : \"$MBSA_ROOT/../update_storage\""
echo "Features        : \"$FEATURES\""
echo "TARGET_PLATFORM : \"$TARGET_PLATFORM\""
echo "MBSA_PLATFORM   : \"$MBSA_TARGET_PLATFORM\""

echo

if [ "`uname -s`" = "Darwin" ]; then
	# some extra process info on Mac
	echo "-------------- PROCESS PIDS ----------------"
	ps -o user,pid,ppid,pgid,command
	echo "--------------------------------------------"
	echo
	echo
fi

# sanity checks...
[ -d "$MBSA_ROOT" ] || echo '[WARNING] MBS_ROOT path "$MBS_ROOT" is inconsistent!'
[ -f "$MBSA_ROOT/lib/mbsa.jar" ] || echo '[WARNING] "$MBSA_ROOT/lib/mbsa.jar" path is inconsistent!'
[ -f "$MBSA_CONFIG/mbsal.core.prs" ] || echo '[WARNING] "$MBSA_CONFIG/mbsal.core.prs" path is inconsistent!'
[ -d "$MBSA_ROOT/lib/runtimes/$MBSA_TARGET_PLATFORM" ] || echo '[WARNING] "$MBSA_ROOT/lib/runtimes/$MBSA_TARGET_PLATFORM" path is inconsistent!'
[ -d "$MBSA_ROOT/lib/runtimes/$MBSA_TARGET_PLATFORM/plugins" ] || echo '[WARNING] "$MBSA_ROOT/lib/runtimes/$MBSA_TARGET_PLATFORM/plugins" path is inconsistent!'

echo