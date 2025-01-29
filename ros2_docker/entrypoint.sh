#!/bin/bash
set -e

# Source ROS 2 Foxy setup file
source /opt/ros/foxy/setup.bash

# Source the workspace (if it exists)
if [ -f "/root/ros2_ws/install/setup.bash" ]; then
    source /root/ros2_ws/install/setup.bash
fi

# Execute the passed command
exec "$@"

