#!/bin/bash

export TZ=${TZ:-"Asia/Shanghai"}

echo ${TZ} >/etc/timezone && dpkg-reconfigure -f noninteractive tzdata
