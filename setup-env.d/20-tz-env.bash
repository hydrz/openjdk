#!/bin/bash

export TZ=${TZ:-"Asia/Shanghai"}
ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime && dpkg-reconfigure -f noninteractive tzdata
