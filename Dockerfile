FROM ros:jazzy-ros-base-noble
ENV ROS2_WS /workspaces
ENV ROS_DOMAIN_ID=1
ENV ROS_DISTRO=jazzy
ARG THREADS=4
ARG TARGETPLATFORM

SHELL ["/bin/bash", "-c"]

##### Copy Source Code #####
COPY . /tmp

##### Environment Settings #####
WORKDIR /tmp

##### Entrypoint & Colcon Rebuild Script #####
RUN mkdir -p ${ROS2_WS}/src && \
    mv /tmp/rebuild_colcon.rc ${ROS2_WS} && \
    mv /tmp/ros_entrypoint.bash /ros_entrypoint.bash && \
    chmod +x /ros_entrypoint.bash && \
    apt update && \
    apt upgrade -y && \
    apt autoremove -y && \
    apt autoclean -y

##### System Package Installation #####
RUN apt install -y \
        aspell \
        axel \
        bash-completion \
        bat \
        bmon \
        build-essential \
        clang-format \
        colordiff \
        cppcheck \
        curl \
        git \
        htop \
        libncurses5-dev \
        libncursesw5-dev \
        lsof \
        nano \
        ncdu \
        nvtop \
        python3-pip \
        python3-venv \
        python3-dev \
        screen \
        tig \
        tmux \
        tree \
        udev \
        vim \
        wget

# Ubuntu Noble's system pip refuses global installs (PEP 668 / externally-managed-environment).
# This image intentionally installs into the system Python, so opt out globally.
RUN printf "[install]\nbreak-system-packages = true\n" > /etc/pip.conf

RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir -r /tmp/requirements.txt && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    ln -s /usr/bin/batcat /usr/bin/bat && \
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" && \
    mv /tmp/.bashrc /root && \
    ln -s /root/.bashrc /.bashrc && \
    /lib/systemd/systemd-udevd --daemon || true

##### ROS2 Installation #####
RUN apt install -y \
        python3-colcon-common-extensions \
        python3-colcon-mixin \
        python3-rosdep \
        python3-vcstool \
        ros-${ROS_DISTRO}-ros-base \
        ros-${ROS_DISTRO}-rosbridge-suite \
        ccache \
        ros-${ROS_DISTRO}-fastrtps \
        ros-${ROS_DISTRO}-rmw-fastrtps-cpp \
        ros-${ROS_DISTRO}-rmw-fastrtps-dynamic-cpp \
        ros-${ROS_DISTRO}-domain-bridge

##### C++ Libraries #####
RUN apt install -y \
        libboost-all-dev \
        libboost-program-options-dev \
        libboost-system-dev \
        libboost-thread-dev \
        libserial-dev \
        nlohmann-json3-dev

# Skip the default rosdep source list so `rosdep init` can be re-run
# without failing on repeated/cached image builds.
RUN rm -f /etc/ros/rosdep/sources.list.d/20-default.list && \
    rosdep init && \
    rosdep update --rosdistro $ROS_DISTRO && \
    (colcon mixin remove default || true) && \
    colcon mixin add default \
        https://raw.githubusercontent.com/colcon/colcon-mixin-repository/master/index.yaml && \
    colcon mixin update && \
    (colcon metadata remove default || true) && \
    colcon metadata add default \
        https://raw.githubusercontent.com/colcon/colcon-metadata-repository/master/index.yaml && \
    colcon metadata update && \
    rm -rf /tmp/* && \
    rm -rf /temp/* && \
    rm -rf /var/lib/apt/lists/*

WORKDIR ${ROS2_WS}
ENTRYPOINT [ "/ros_entrypoint.bash" ]
CMD ["bash", "-l"]
