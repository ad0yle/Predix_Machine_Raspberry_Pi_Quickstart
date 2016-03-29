TERMS OF USE: USE OF THIS SOFTWARE IS GOVERNED BY THE SOFTWARE LICENSING AND DISTRIBUTION AGREEMENT
STATED IN THE DOCUMENTS license/Predix_EULA.pdf (THESE DOCUMENTS ARE PART OF THIS
SOFTWARE PACKAGE). BY USING THIS SOFTWARE, YOU AGREE THAT YOUR USE OF THE SOFTWARE IS GOVERNED BY
LICENSING AND DISTRIBUTION AGREEMENT STATED IN THESE DOCUMENTS. IF YOU DO NOT FULLY AGREE WITH THE
TERMS OF THE AGREEMENTS, YOU ARE NOT AUTHORIZED TO USE THE SOFTWARE AND MUST REMOVE THE SOFTWARE
IMMEDIATELY.

Predix Machine is a lightweight kernel that can be deployed on various OSGi
containers. Predix Machine should be unzipped and placed in your software development workspace. 
      
Once the container is extracted, the scripts for launching it can be found in ./machine/bin/predix/

Additional README files can be found in sub folders. 

=====================================================================
Folder Structure
=====================================================================

/--
    /appdata - Application created data. This can include git repositories or databases.
    
    /configuration/machine - bundle configuration, property files and system properties 
        /machine - machine container configuration
        /install - (optional) installation scripts used by yeti to install configuration on the device.
     
    /installations - (optional) location for yeti to monitor for install zips.
    
    /licence - legal documents
    
    /logs - log files if file logging is setup. These will be grouped by application.
        /machine
        /mbsa (optional)
    
    /machine- The ProSyst container
        /bin
            /predix - contains startup scripts. start by running "predixmachine"
            /vms
                boot.ini - list of ProSyst bundles and their start order.
                /jdk
                    server or server.bat - ProSyst start script.
                    /storage - framework runtime storage.  During a clean start, the contents of this folder will be deleted.
        /bundles - the ProSyst bundles
        /config - used for storing configuration for OSGi meta-types.
        /install - (optional) installation scripts used by yeti to install machine on the device.
        /lib  - native libraries and frameworks
    
    /mbsa - (optional) if the mbsa option is selected
        /bin - start/stop scripts
        /install - installation scripts used by yeti to install on the device.
        /lib - native libraries and frameworks

    /security - setup bundle level security and key and trust stores
    
    /yeti - (optional) process to monitor the installations folder and install packages from the Device Management in the cloud.


=====================================================================
Custom configuration
=====================================================================
      
The container startup sequence is defined in *.ini, located in ./machine/bin/vms/. 

You can choose to not load certain modules, by removing them from the ini file, 
if your application does not require them. For example, if you don't 
need the TCP socket service or its protobuf library dependency, 
you can remove 
        <bundle>
            <name>protobuf-java-2.5.0.jar</name>
        </bundle>
    