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

source /opt/ros/jazzy/setup.bash
source /etc/profile.d/bash_completion.sh
export PATH="/usr/lib/ccache:$PATH"
source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash

alias sl=ls
alias l="ls -lash"
alias r="source /workspaces/rebuild_colcon.rc"
alias b="ros2 launch rosbridge_server rosbridge_websocket_launch.xml"
alias m="make -j"
alias diff=colordiff
