#!/bin/sh
SKIP_BOOTINI="true"
PROCESSOR=arm-raspbian
export SKIP_BOOTINI PROCESSOR 

# *** Global configuration - EDIT THE VALUES BELOW IF YOU WANT TO ENABLE SOME FEATURE WITHOUT PASSING PARAMETERS
# * an integer in the interval [14,18]
[ -z "$VM_VERSION" ] &&  VM_VERSION="15"

# * vm specific code - save to change though not recommended
VM_ARGS_v14=
VM_ARGS_v15=
JIT="-Djava.compiler="

# *** DO NOT EDIT BELOW!!!!!

# a call-back function
Execute () {
	export LD_LIBRARY_PATH
	# * setup extra bootclasspath if not framework loader is set
	if [ -z "$FWLOADER" ]; then if [ -n "$MBS_SERVER_JAR" ]; then mCP="$MBS_SERVER_JAR"; fi; fi
	# * set classpath
	if [ -n "$FWAPPCP" ]; then
		CP="-cp $_SERVER:$mCP:../../../lib/framework/fwtime.jar:$EXTRA_CP";
	else
		CP="-Xbootclasspath/a:$_SERVER:$mCP -cp ../../../lib/framework/fwtime.jar:$EXTRA_CP";
	fi
	# * set boot class path
	if [ -n "$BOOTCP" ]; then BOOTCP="-Xbootclasspath/p:$BOOTCP"; fi
	# * remote debugging
	XDBG=
	if [ -n "$VM_DEBUG" ]; then
		if [ -n "$VM_DEBUG_SUSPEND" ]; then XDBG="y"; else XDBG="n"; fi
		if [ "$VM_VERSION" -ge "15" ]; then
			XDBG="-agentlib:jdwp=transport=dt_socket,server=y,address=0.0.0.0:$VM_DEBUG_PORT,suspend=$XDBG";
		else
			XDBG="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,address=$VM_DEBUG_PORT,suspend=$XDBG";
		fi
	fi
	# * execute
	echo $JAVA $VM_ARGS $XDBG $BOOTCP $CP $FEATURES $FWCLEAN $MAIN_CLASS
	if [ -z "$FWDUMPCMD" ]; then
		$JAVA $VM_ARGS $XDBG $BOOTCP $CP $FEATURES $FWCLEAN $MAIN_CLASS
	fi
}

# *** VM setup
SetupVM () {
	# Setup the java virtual machine
	FindVM "java" "$JAVA_HOME"
}


# needed by server_common.sh

# *** parse
while [ -n "$1" ]; do
	case $1 in
# * version
		-jdk1.4|jdk1.4)
			VM_VERSION="14";;
		-jdk1.5|jdk1.5)
			VM_VERSION="15";;
		-jdk1.6|jdk1.6)
			VM_VERSION="15" 
			VM_ARGS_v15="$VM_ARGS_v15 -Dsun.lang.ClassLoader.allowArraySyntax=true"
			;;
# * delegate to common
		*)
			_ARGS="$_ARGS $1" ;;
	esac
	shift # * shift to next argument
done

# *** setup
# * set defaults
if [ -z "$VM_VERSION" ]; then VM_VERSION="15"; fi
# * version specific parameters, disable JIT & enables some optimizations
case $VM_VERSION in
		14) VM_ARGS="$VM_ARGS $VM_ARGS_v14" ;;
		15) VM_ARGS="$VM_ARGS $VM_ARGS_v15" ;;
		16|17|18) 
			VM_VERSION="15"
			VM_ARGS_v15="$VM_ARGS_v15 -Dsun.lang.ClassLoader.allowArraySyntax=true"
			VM_ARGS="$VM_ARGS $VM_ARGS_v15"
			;;
esac
# * server setup
_SERVER="../../../lib/framework/serverjvm$VM_VERSION$_SERVER_SUFFIX.jar"

# run main
. ../server_common.sh
