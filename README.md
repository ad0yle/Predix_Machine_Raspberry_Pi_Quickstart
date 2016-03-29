# Predix Machine Raspberry Pi Quickstart
Quickstart to set up a new Raspberry Pi with Predix Machine and have it stream to the Predix Cloud

Target                    |
:-------------------------:|
![Next Gen Architecture](https://github.build.ge.com/github-enterprise-assets/0000/0098/0000/1279/52fc83de-c376-11e5-98ec-00e166dbaf56.png)

## Intro
Welcome Predix Developers! This product is a reference application for Predix that exposes various micro services for demo, quick setup, and configuration purposes. It does this by pushing time series data from your Raspberry Pi  to Predix Time Series Service and be viewable via the front-end which uses the Predix Seed. Run the `quickstart` script to setup a instance of time series, UAA, Asset and push a Front-End demo application to Cloud Foundry. This gives a basic idea of how various Predix micro services can be hooked together and configured quickly and easily.

## Raspberry Pi Configuration

You could go through all the steps to build and export your own Predix Machine container, or you could just use the container PredixMachine_16.1.0.zip included in this repo.  I suggest using the container that has already been created and then when you want to understand the internals more, follow the following documentation for a deeper dive on configuring your Raspberry Pi: https://devcloud.swcoe.ge.com/devspace/display/~212411278/Install+Predix+Machine+onto+a+RaspberryPi

## Development machine configurations and step-by-step to building Predix Application and Services

Before running the script, on your development machine (not your Raspberry Pi), please make sure that you install Cloud Foundry and UAA by completing the following steps.

1. Install CF CLI (Cloud Foundry Command Line Interface) from this website: https://github.com/cloudfoundry/cli.  
  a. Go to the Downloads Section of the README on the GitHub and download the correct package or binary for your operating system.  
  b. Check that it is installed by typing “cf” on your command line.  

2. Download the UAAC (Cloud Foundry UAA Client) by typing “ gem install cf-uaac” on the command line.  For more information, visit https://docs.cloudfoundry.org/adminguide/uaa-user-management.html.

3. Be sure to set your environment proxy variables before trying to run the script.
Check that the version is at least 3.1.6, by running `uaac -v`

4. Be sure to set your environment proxy variables before trying to run the script.

```
export ALL_PROXY=http://<proxy-host>:<proxy-port>
export HTTP_PROXY=$ALL_PROXY
export HTTPS_PROXY=$ALL_PROXY
export http_proxy=$ALL_PROXY
export https_proxy=$ALL_PROXY
```

5. Once the above steps are completed, you can start configuring the scripts.  Open the file `variables.sh` in a text editor.  This file contains environment variables that are used in `quickstart.sh` and they need to be filled out before using the script. Services and plans are set to the default values for the Predix VPC. See the comments in the file for more information.
    1. By default, the Cloud Foundry Organization and the username is your email
    2. By default, no proxy host:port is set

6. Now you’re ready to run the scripts.

  1. Type `./cleanup.sh`. This script is responsible for deleting the applications and services created from the `quickstart.sh` script. If any error occurs, try rerunning the script. Network issues can sometimes cause issues when deleting applications or services.
  2. Type `./quickstart.sh`. First you will be prompted for your Cloud Foundry password. After that the script will begin setting up the various micro services, hooking them together using the parameters set in the `variables.sh` file.
  3. If any errors occurs during `quickstart.sh`, run the  `cleanup.sh` script and try to run `quickstart.sh` again. If errors persist, there might be an issue establishing a reliable connection with Cloud Foundry or Predix.

7.	Upon completion, your Predix App has been set up and your Predix Machine is now ready to be ported over to the Raspberry Pi
  1. More Documentation will follow here how to port it over, placeholder for now.

8.	After the script is complete, run the command 'cf apps' to see the list of cloud foundry apps you have created. Within that list the app pushed by the script will have the name set in the variables.sh file. Under the 'urls' heading in that apps' row the url used for the front-end will be available. Navigating to that url will show a time series graph representation of the simulation data displayed using the Predix Seed.

  1. If you don’t see data, make sure that the correct machine configurations are set, and that your Raspberry PI is correctly set up. Refer to additional instructions below. https://devcloud.swcoe.ge.com/devspace/pages/viewpage.action?spaceKey=~212411278&title=Install+Predix+Machine+onto+a+RaspberryPi


Congratulations! You have successfully created your first Predix Application! You are now a Predix Developer!


## Scripts and their operations
### variables.sh
This script contains the global variable values used by the most Scripts
### cleanup.sh
This script is responsible for deleting all applications, and service instances created from `quickstart.sh`
### quickstart.sh
This script performs the bulk of the work needed to set up the sample application.
1.  We first login to Cloud Foundry and push a temp app that will allow us to create Predix Service instances and update their configurations such as scope, authorities and creating any required clients
2.  After setting up the Predix services, we post a 'sample' asset to the Asset service and modify any required Predix Machine configurations relating to pushing data via WebSockets. These modifications are done by the `machineconfig.sh` script
  a. Before pushing the actual front-end-app, we copy over the required `config.json` to the root directory of the app-front-end app. This JSON file specifies the necessary credentials and properties required to allow the app to communicate/query with Predix Asset and TimeSeries
3.  Lastly we delete the temp-app, push the actual front-end-app, bind all Predix Services to the app, and start the app.
### machineconfig.sh
This script will do a Find and Replace on the required configurations that need to be changed in order to have Predix Machine correctly push simulated data to the created Predix TimeSeries Service.
