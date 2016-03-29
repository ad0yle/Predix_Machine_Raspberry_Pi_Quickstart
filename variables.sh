#Predix Cloud Foundry Credentials

#Proxy settings
ALL_PROXY=<proxy_host>:<proxy_port>

#Cloud Foundry Host Domain Name
CF_HOST=api.system.aws-usw02-pr.ice.predix.io
#Cloud Foundry Organization
CF_ORG=<my.org>
#Could Foundry Space
CF_SPACE=dev
#Your Cloud Foundry Username
CF_USERNAME=<my.predix.account.email@myorg.com>

#Name for your Reference Application Front End
FRONT_END_APP_NAME=predix-ref-app-frontend

#Name for the temp_app application
TEMP_APP=my-temp-app

#Predix UAA Credentails
#The name of the UAA service you are binding to
UAA_SERVICE_NAME=predix-uaa
#Name of the UAA plan (eg: Free)
UAA_PLAN=Tiered
#Name of your UAA instance (Can be anything you want)
UAA_INSTANCE_NAME=predix-ref-app-uaa
#The secret of the Admin client ID (Administrator Credentails)
UAA_ADMIN_SECRET=secret

#Predix TimeSeries Credentials
#The name of the TimeSeries service you are binding to
TIMESERIES_SERVICE_NAME=predix-timeseries
#Name of the TimeSeries plan (eg: Free)
TIMESERIES_SERVICE_PLAN=Bronze
#Name of your TimeSeries instance (Can be anything you want)
TIMESERIES_INSTANCE_NAME=predix-ref-app-timeseries
#Client ID to query and ingest to Time Series
TIMESERIES_CLIENT_ID=ts-client
#Secret for the client ID above
TIMESERIES_CLIENT_SECRET=secret

#Predix Asset Credentials
#The name of the Asset service you are binding to
ASSET_SERVICE_NAME=predix-asset
#Name of the Asset plan (eg: Free)
ASSET_SERVICE_PLAN=Tiered
#Name of your Asset instance (Can be anything you want)
ASSET_INSTANCE_NAME=predix-ref-app-asset
#Client ID to Post and query Asset service
ASSET_CLIENT_ID=asset-client
#Secret for the client ID above
ASSET_CLIENT_SECRET=secret

#Predix Machine Credentials
#Name of the "machine" that is recorded to Predix Asset
MACHINE_TYPE="WindTurbine"
#Name of the tag (Machine name ex: Wind Turbine) you want to ingest to timeseries with
#(For this reference application demo purposes do not change this tag)
MACHINE_TAG=wind_turbine_v1
#Description of the Machine that is recorded to Predix Asset
MACHINE_DESCRIPTION="Wind Turbine that generates power version 1"
