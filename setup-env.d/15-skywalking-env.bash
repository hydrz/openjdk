#!/bin/bash

export SW_ENABLE=${SW_ENABLE:-"false"}

if is_true "$SW_ENABLE"; then
    SW_AGENT=$(readlink -f ./skywalking/skywalking-agent.jar)
    export SW_OPTS=${SW_OPTS:-"-javaagent:${SW_AGENT}"}
fi
