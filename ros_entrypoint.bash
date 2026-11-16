#!/bin/bash
set -e

# 0666 SHM segments so non-root host processes can share Fast DDS memory
umask 000

# ROS, $ROS_UNDERLAY and the $ROS2_WS overlay are sourced at the top of .bashrc,
# shared with `docker exec -it <container> bash`.
source /root/.bashrc
exec "$@"
