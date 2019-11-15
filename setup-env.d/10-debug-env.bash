#!/bin/bash

export DBG_ENABLE=${DBG_ENABLE:-"true"}

if is_true "$DBG_ENABLE"; then
    export DBG_AGENT="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005"
    export DBG_AGENT="${DBG_AGENT} -Dcom.sun.management.jmxremote.port=5006 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false"
fi
