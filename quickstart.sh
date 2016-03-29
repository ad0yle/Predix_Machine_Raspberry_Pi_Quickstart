#!/bin/bash
set -e
# Predix Dev Bootstrap Script
# Authors: GE SDLP 2015
#
# Welcome new Predix Developers! Run this script to setup a instance of UAA, TimeSeries, Asset, push a front end applicationm and setup Predix machine.
# This will give you a basic idea of how GE Predix works!
#

#Be sure to set all your variables in the variables.sh file before you run quick start!
source variables.sh

echo -e "Welcome to the Predix Quick start script!\n"

echo -e " ### Logging in to Cloud Foundry ### \n"
echo "ENTER YOUR PASSWORD NOW followed by ENTER"
read -s CF_PASSWORD
cf login -a $CF_HOST -u $CF_USERNAME -p $CF_PASSWORD -o $CF_ORG -s $CF_SPACE --skip-ssl-validation

#Create instace of Predix UAA Service
cf cs $UAA_SERVICE_NAME $UAA_PLAN $UAA_INSTANCE_NAME -c "{\"adminClientSecret\":\"$UAA_ADMIN_SECRET\"}"

#Push a test app to get credentials
echo -e " ### Pushing $TEMP_APP to initially create Predix Microservices ... ###\n"

cd testapp
cf push $TEMP_APP --no-start --random-route

#Bind Front End App to UAA instance
cf bs $TEMP_APP $UAA_INSTANCE_NAME

#Get the UAA URI from the enviorment variables (VCAPS)
trustedIssuerID=$(cf env $TEMP_APP | grep predix-uaa* | grep issuerId*| awk 'BEGIN {FS=":"}{print "https:"$3}' | awk 'BEGIN {FS="\","}{print $1}' )
uaaURL=$(cf env $TEMP_APP | grep predix-uaa* | grep uri*| awk 'BEGIN {FS=":"}{print "https:"$3}' | awk 'BEGIN {FS="\","}{print $1}' )

#Create instance of Predix TimeSeries Service
cf cs $TIMESERIES_SERVICE_NAME $TIMESERIES_SERVICE_PLAN $TIMESERIES_INSTANCE_NAME -c "{\"trustedIssuerIds\":[\"$trustedIssuerID\"]}"

#Bind Front End App to TimeSeries Instance
cf bs $TEMP_APP $TIMESERIES_INSTANCE_NAME

#Get the Zone ID from the enviroment variables (for use when querying and ingesting data)
TIMESERIES_ZONE_ID=$(cf env $TEMP_APP | grep -m 1 zone-http-header-value | sed 's/"zone-http-header-value": "//' | sed 's/",//' | tr -d '[[:space:]]')
TIMESERIES_INGEST_URI=$(cf env $TEMP_APP | grep -m 1 uri | sed 's/"uri": "//' | sed 's/",//' | tr -d '[[:space:]]')
TIMESERIES_QUERY_URI=$(cf env $TEMP_APP | grep -m 2 uri | grep https | sed 's/"uri": "//' | sed 's/",//' | tr -d '[[:space:]]')

#Create instance of Predix Asset Service
cf cs $ASSET_SERVICE_NAME $ASSET_SERVICE_PLAN $ASSET_INSTANCE_NAME -c "{\"trustedIssuerIds\":[\"$trustedIssuerID\"]}"

#Bind Front End App to Asset Instance
cf bs $TEMP_APP $ASSET_INSTANCE_NAME

#Get the Zone ID from the enviroment variables (for use when querying and posting data)
ASSET_ZONE_ID=$(cf env $TEMP_APP | grep -m 1 http-header-value | sed 's/"http-header-value": "//' | sed 's/",//' | tr -d '[[:space:]]')
#
#Login to UAA
uaac target $uaaURL
uaac token client get admin -s $UAA_ADMIN_SECRET #Give UAA context so it knows the admin credentials it has to run commands under

#Create client ID for ingesting and querying TimeSeries  ID, name, secret
uaac client add $TIMESERIES_CLIENT_ID --authorized_grant_types "client_credentials"  --name $TIMESERIES_CLIENT_ID -s $TIMESERIES_CLIENT_SECRET

#Update scopes for the client ID with zone ID of TimeSeries Instance
uaac client update $TIMESERIES_CLIENT_ID --authorities "timeseries.zones.$TIMESERIES_ZONE_ID.user,timeseries.zones.$TIMESERIES_ZONE_ID.query,timeseries.zones.$TIMESERIES_ZONE_ID.ingest" --scope "timeseries.zones.$TIMESERIES_ZONE_ID.user,timeseries.zones.$TIMESERIES_ZONE_ID.querytimeseries.zones.$TIMESERIES_ZONE_ID.ingest"

#Create client ID for posting and querying Asset"
uaac client add $ASSET_CLIENT_ID --authorized_grant_types "client_credentials" --name $ASSET_CLIENT_ID -s $ASSET_CLIENT_SECRET

#Update scopes for the client ID with zone ID of Asset Instance
#uaac client update $ASSET_CLIENT_ID --authorities "$ASSET_SERVICE_NAME.zones.$ASSET_ZONE_ID.user" --scope "$ASSET_SERVICE_NAME.zones.$ASSET_ZONE_ID.user"
uaac client update $ASSET_CLIENT_ID --authorities "$ASSET_SERVICE_NAME.zones.$ASSET_ZONE_ID.user uaa.none" --scope "$ASSET_SERVICE_NAME.zones.$ASSET_ZONE_ID.user uaa.none"

assetURI=$(cf env $TEMP_APP | grep uri*| grep asset* | awk 'BEGIN {FS=":"}{print "https:"$3}' | awk 'BEGIN {FS="\","}{print $1}')
assetPostBody=$(printf '[{"uri": "%s", "tag": "%s", "description": "%s"}]%s' "/$MACHINE_TYPE/$MACHINE_TAG" "$MACHINE_TAG" "$MACHINE_DESCRIPTION")

cd ../Asset-Post-Util-OS

# Call the correct Asset-Post-Util depending on the OS
if [ "$(uname -s)" == "Darwin" ]
then
	cd OSx
	echo -e " ### Posting asset data to Predix Asset using OSx ###\n"
	./Asset-Post-Util $uaaURL $assetURI/$MACHINE_TYPE $ASSET_CLIENT_ID $ASSET_CLIENT_SECRET $ASSET_ZONE_ID "$assetPostBody"
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]
then
	cd Linux
	echo -e " ### Posting asset data to Predix Asset using Linux ###\n"
	./Asset-Post-Util $uaaURL $assetURI/$MACHINE_TYPE $ASSET_CLIENT_ID $ASSET_CLIENT_SECRET $ASSET_ZONE_ID "$assetPostBody"
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]
then
	# First unzip the file to get the exe
  cd Win
  unzip -o Asset-Post-Util.zip
	echo -e " ### Posting asset data to Predix Asset using Windows ###\n"
  ./Asset-Post-Util.exe $uaaURL $assetURI/$MACHINE_TYPE $ASSET_CLIENT_ID $ASSET_CLIENT_SECRET $ASSET_ZONE_ID "$assetPostBody"
fi

cd ../..
echo -e " ### Deleting the $TEMP_APP ###\n"
cf d $TEMP_APP -f

echo -e " ### Setting predix machine configurations ###\n"
./machineconfig.sh $trustedIssuerID $TIMESERIES_INGEST_URI $TIMESERIES_ZONE_ID $uaaURL

# Call the correct zip depending on the OS
if [ "$(uname -s)" == "Darwin" ]
then
	echo -e " ### Zipping up the configured Predix Machine and storing in PredixMachineContainer.zip  ###\n"
	zip -r PredixMachineContainer.zip PredixMachine_16.1.0
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]
then
	echo -e " ### You must manually zip of PredixMachine_16.1.0 to port it to the Raspberry Pi ###\n"
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]
then
	echo -e " ### You must manually zip of PredixMachine_16.1.0 to port it to the Raspberry Pi ###\n"
fi

echo -e " ### Starting the $FRONT_END_APP_NAME with the configurations found in the config.json file ###\n"
echo $(printf '{"uaaURL": "%s", "timeseriesURL": "%s", "assetURL": "%s", "ts_client": "%s", "ts_secret": "%s", "ts_zone": "%s", "tagname": "%s", "asset_client": "%s", "asset_secret": "%s", "asset_zone": "%s"}' $trustedIssuerID $TIMESERIES_QUERY_URI "$assetURI/$MACHINE_TYPE/$MACHINE_TAG" $TIMESERIES_CLIENT_ID $TIMESERIES_CLIENT_SECRET $TIMESERIES_ZONE_ID $MACHINE_TAG $ASSET_CLIENT_ID $ASSET_CLIENT_SECRET $ASSET_ZONE_ID) > config.json
cp -R "config.json" "app-front-end/config.json"

cd app-front-end
cf push $FRONT_END_APP_NAME --no-start --random-route
cf bs $FRONT_END_APP_NAME $UAA_INSTANCE_NAME
cf bs $FRONT_END_APP_NAME $TIMESERIES_INSTANCE_NAME
cf bs $FRONT_END_APP_NAME $ASSET_INSTANCE_NAME
cf start $FRONT_END_APP_NAME

cd ..

echo "Predix Dev Bootstrap Configuration" > config.txt
echo "Authors SDLP v1 2015" >> config.txt
echo "UAA URL: $uaaURL" >> config.txt
echo "UAA Admin Client ID: admin" >> config.txt
echo "UAA Admin Client Secret: $UAA_ADMIN_SECRET" >> config.txt
echo "TimeSeries Ingest URL:  $TIMESERIES_INGEST_URI" >> config.txt
echo "TimeSeries Query URL:  $TIMESERIES_QUERY_URI" >> config.txt
echo "TimeSeries Client ID: $TIMESERIES_CLIENT_ID" >> config.txt
echo "TimeSeries Client Secret: $TIMESERIES_CLIENT_SECRET" >> config.txt
echo "TimeSeries ZoneID: $TIMESERIES_ZONE_ID" >> config.txt
echo "Asset URL:  $assetURI" >> config.txt
echo "Asset Client ID: $ASSET_CLIENT_ID" >> config.txt
echo "AssetClient Secret: $ASSET_CLIENT_SECRET" >> config.txt
echo "Asset Zone ID: $ASSET_ZONE_ID" >> config.txt

echo -e "Restaging to make sure all variables are synced and services wired..."
cf restage $FRONT_END_APP_NAME

echo -e "You can execute 'cf env "$FRONT_END_APP_NAME"' to view all this information\n"
echo -e "Now we are ready to start our 'Machine'\n"
echo -e "In a separate terminal window run 'machine-start.sh'\n"
echo -e "In your web browser, navigate to your front end application endpoint found below\n"
cf a
