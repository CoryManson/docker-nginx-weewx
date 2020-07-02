#!/usr/bin/env bash
set +e
su abc -c "PATH=/home/weewx/bin weewxd /home/weewx/weewx.conf|grep -v LOOP:"

su root -c "/home/weewx/bin/weewxd /home/weewx/weewx.conf --daemon"