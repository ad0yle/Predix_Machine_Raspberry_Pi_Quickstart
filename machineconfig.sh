# Predix Machine Config Setup Script (used within quickstart.sh)
# Authors: GE SDLP 2015-2016
# Expected inputs:
# issuerId_under_predix_uaa
# Timeseries_ingest_uri
# Timeseries_zone_id
# uri_under_predix_uaa

source variables.sh

cd PredixMachine_16.1.0/configuration/machine/
sed "s#com.ge.dspmicro.predixcloud.identity.uaa.token.url=.*#com.ge.dspmicro.predixcloud.identity.uaa.token.url=\"$1\"#" com.ge.dspmicro.predixcloud.identity.config > com.ge.dspmicro.predixcloud.identity.config.tmp
mv com.ge.dspmicro.predixcloud.identity.config.tmp com.ge.dspmicro.predixcloud.identity.config

sed "s#com.ge.dspmicro.predixcloud.identity.uaa.clientid=.*#com.ge.dspmicro.predixcloud.identity.uaa.clientid=\"$TIMESERIES_CLIENT_ID\"#" com.ge.dspmicro.predixcloud.identity.config > com.ge.dspmicro.predixcloud.identity.config.tmp
mv com.ge.dspmicro.predixcloud.identity.config.tmp com.ge.dspmicro.predixcloud.identity.config

sed "s#com.ge.dspmicro.predixcloud.identity.uaa.clientsecret=.*#com.ge.dspmicro.predixcloud.identity.uaa.clientsecret=\"$TIMESERIES_CLIENT_SECRET\"#" com.ge.dspmicro.predixcloud.identity.config > com.ge.dspmicro.predixcloud.identity.config.tmp
mv com.ge.dspmicro.predixcloud.identity.config.tmp com.ge.dspmicro.predixcloud.identity.config

sed "s#com.ge.dspmicro.predixcloud.identity.oauth.authorize.url=.*#com.ge.dspmicro.predixcloud.identity.oauth.authorize.url=\"$4\"#" com.ge.dspmicro.predixcloud.identity.config > com.ge.dspmicro.predixcloud.identity.config.tmp
mv com.ge.dspmicro.predixcloud.identity.config.tmp com.ge.dspmicro.predixcloud.identity.config

sed "s#com.ge.dspmicro.predixcloud.identity.uaa.enroll.url=.*#com.ge.dspmicro.predixcloud.identity.uaa.enroll.url=\"$1\"#" com.ge.dspmicro.predixcloud.identity.config > com.ge.dspmicro.predixcloud.identity.config.tmp
mv com.ge.dspmicro.predixcloud.identity.config.tmp com.ge.dspmicro.predixcloud.identity.config

sed "s#com.ge.dspmicro.websocketriver.send.destination.url=.*#com.ge.dspmicro.websocketriver.send.destination.url=\"$2\"#" com.ge.dspmicro.websocketriver.send-0.config > com.ge.dspmicro.websocketriver.send-0.config.tmp
mv com.ge.dspmicro.websocketriver.send-0.config.tmp com.ge.dspmicro.websocketriver.send-0.config

sed "s#com.ge.dspmicro.websocketriver.send.header.zone.value=.*#com.ge.dspmicro.websocketriver.send.header.zone.value=\"$3\"#" com.ge.dspmicro.websocketriver.send-0.config > com.ge.dspmicro.websocketriver.send-0.config.tmp
mv com.ge.dspmicro.websocketriver.send-0.config.tmp com.ge.dspmicro.websocketriver.send-0.config

sed "s#<register name=.*dataType=.*address=.*registerType=.*description=.*/>#<register name=\"$MACHINE_TAG\" dataType=\"FLOAT\" address=\"0\" registerType=\"HOLDING\" description=\"temperature\"/>#" com.ge.dspmicro.machineadapter.modbus-0.xml > com.ge.dspmicro.machineadapter.modbus-0.xml.tmp
mv com.ge.dspmicro.machineadapter.modbus-0.xml.tmp com.ge.dspmicro.machineadapter.modbus-0.xml

sed "s#<nodeName>.*</nodeName>#<nodeName>$MACHINE_TAG</nodeName>#" com.ge.dspmicro.machineadapter.modbus-0.xml > com.ge.dspmicro.machineadapter.modbus-0.xml.tmp
mv com.ge.dspmicro.machineadapter.modbus-0.xml.tmp com.ge.dspmicro.machineadapter.modbus-0.xml

if [[ ! -z $ALL_PROXY ]]
then
	myProxyHostValue=${ALL_PROXY%:*}
	myProxyPortValue=${ALL_PROXY##*:}
	myProxyEnabled="true"
else
	myProxyHostValue=""
	myProxyPortValue=""
	myProxyEnabled="false"
fi

sed "s#proxy.host=.*#proxy.host=\"$myProxyHostValue\"#" org.apache.http.proxyconfigurator-0.config > org.apache.http.proxyconfigurator-0.config.tmp
mv org.apache.http.proxyconfigurator-0.config.tmp org.apache.http.proxyconfigurator-0.config

sed "s#proxy.port=I.*#proxy.host=I\"$myProxyPortValue\"#" org.apache.http.proxyconfigurator-0.config > org.apache.http.proxyconfigurator-0.config.tmp
mv org.apache.http.proxyconfigurator-0.config.tmp org.apache.http.proxyconfigurator-0.config

sed "s#proxy.enabled=B.*#proxy.enabled=B\"$myProxyEnabled\"#" org.apache.http.proxyconfigurator-0.config > org.apache.http.proxyconfigurator-0.config.tmp
mv org.apache.http.proxyconfigurator-0.config.tmp org.apache.http.proxyconfigurator-0.config
