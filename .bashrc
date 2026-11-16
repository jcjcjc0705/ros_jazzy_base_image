# ── ROS environment: every shell that reads this file, interactive or not ───
# ros_entrypoint.bash sources this file too, so `docker run` and
# `docker exec -it <container> bash` end up with the same environment.
# The trailing `--` keeps the container command (the entrypoint's arguments) from
# being passed on to the setup scripts.
source "/opt/ros/$ROS_DISTRO/setup.bash" --
# Underlay a derived image built into itself, e.g. ros2_control_image sets
# ROS_UNDERLAY=/opt/ros2_control_ws/install. Its setup.bash chains to the layers below.
if [ -n "$ROS_UNDERLAY" ] && [ -f "$ROS_UNDERLAY/setup.bash" ]; then
    source "$ROS_UNDERLAY/setup.bash" --
fi
# Overlay: packages built in $ROS2_WS (e.g. bind-mounted source, built with `r`).
if [ -f "$ROS2_WS/install/setup.bash" ]; then
    source "$ROS2_WS/install/setup.bash" --
fi

# Enable the subsequent settings only in interactive sessions
case $- in
  *i*) ;;
    *) return;;
esac

# 0666 SHM segments so non-root host processes can share Fast DDS memory
umask 000

# Path to your oh-my-bash installation.
export OSH='/root/.oh-my-bash'

OSH_THEME='agnoster'

OMB_USE_SUDO=true

completions=(
  git
  git_flow
  composer
  ssh
  pip3
)

aliases=(
  general
)

plugins=(
  git
  pyenv
  sudo
  bashmarks
)

source "$OSH"/oh-my-bash.sh

source /etc/profile.d/bash_completion.sh
export PATH="/usr/lib/ccache:$PATH"
source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash

alias sl=ls
alias l="ls -lash"
alias r="source /workspaces/rebuild_colcon.rc"
alias b="ros2 launch rosbridge_server rosbridge_websocket_launch.xml"
alias m="make -j"
alias diff=colordiff
