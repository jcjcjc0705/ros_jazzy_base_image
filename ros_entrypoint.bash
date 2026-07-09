#!/bin/bash
set -e

# 0666 SHM segments so non-root host processes can share Fast DDS memory
umask 000

# setup ros2 environment
source /root/.bashrc
source "/opt/ros/$ROS_DISTRO/setup.bash" --
if [ -f "$ROS2_WS/install/setup.bash" ]; then
    source "$ROS2_WS/install/setup.bash"
else
    echo "Warning: setup.bash not found!"
fi
exec "$@"
