#!/bin/bash

export TZ=${TZ:-"Asia/Shanghai"}
export JAVA_TZ_OPTS="-Duser.timezone=${TZ}"

echo "${TZ}" >/etc/timezone
ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime
