#!/bin/bash
export TIMEZONE=${TIMEZONE:-"Asia/Shanghai"} 

cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime 
echo "${TIMEZONE}" > /etc/timezone 

#ENTRYPOINT ["/src/domoticz/domoticz", "-dbase", "/config/domoticz.db", "-log", "/config/domoticz.log", "-sslwww", "0"]
#CMD ["-www", "9080"]

exec /src/domoticz/domoticz -dbase /config/domoticz.db -log /config/domoticz.log -sslwww 0 -www 9080
