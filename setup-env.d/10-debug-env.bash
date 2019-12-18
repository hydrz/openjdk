#!/bin/bash

export DEBUG_ENABLE=${DEBUG_ENABLE:-"false"}

if is_true "$DEBUG_ENABLE"; then
    export DEBUG_AGENT="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005"
    export DEBUG_AGENT="${DEBUG_AGENT} -Dcom.sun.management.jmxremote.port=5006 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false"
fi
