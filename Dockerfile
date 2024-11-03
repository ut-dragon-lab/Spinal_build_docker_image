#This is a Dockerfile to construct the environment where STM32CubeIDE project can be build.
# Reference: https://interrupt.memfault.com/blog/github-actions-for-stm32cubeide
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
# Install dependencies for STM32CubeIDE
RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    ca-certificates \
    # we use git to clone our project when we build in GitHub actions
    git \
    # part of the Cube install script uses "killall", which is in psmisc
    psmisc \
    # we use this to extract the Cube installer
    unzip \
    lsb-release \
    gnupg2 \
    curl
    # don't clear apt cache, the stm32cubeide installer needs it
    # && rm -rf /var/lib/apt/lists/*

# install ros
## add ROS Noetic Repository
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' \
    && curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -
## ROS Noetic install
RUN apt-get update && apt-get install -y \
    ros-noetic-desktop-full
## ROS path setup
RUN echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc
### rosdep initialization
RUN apt-get update && apt-get install -y python3-rosdep \
    # && rm -rf /var/lib/apt/lists/* \
    && rosdep init \
    && rosdep update
## ROS build tools
RUN apt-get update && apt-get install -y \
    python3-catkin-tools
    # && rm -rf /var/lib/apt/lists/*
# set bash as default shell
SHELL ["/bin/bash", "-c"]

# source
CMD ["bash", "-c", "source /opt/ros/noetic/setup.bash && bash"]
ARG STM32CUBE_VERSION=1.8.0_11526_20211125_0815

# Copy the installer file into the image. It needs to be downloaded into the
# directory where the Dockerfile is.
COPY en.st-stm32cubeide_${STM32CUBE_VERSION}_amd64.deb_bundle.sh.zip /tmp/stm32cubeide.sh.zip
RUN mkdir -p /tmp/stm32cubeide && \
    mv /tmp/stm32cubeide.sh.zip /tmp/stm32cubeide/stm32cubeide.sh.zip && \
    cd /tmp/stm32cubeide && \
    unzip stm32cubeide.sh.zip && \
    chmod +x st-stm32cubeide_${STM32CUBE_VERSION}_amd64.deb_bundle.sh && \
    # run the self-unpacker script, but don't actually install anything
    ./st-stm32cubeide_${STM32CUBE_VERSION}_amd64.deb_bundle.sh --target ./ --noexec && \
    # this is required to avoid an error during apt-get install
    chmod a+r /tmp/stm32cubeide/*.deb && \
    chmod 777 /tmp/stm32cubeide/*.deb && \
    # need to set this env var for unattended install. install everything
    # manually, to avoid issues with the installer script, which does not have
    # an unattended install mode.
    LICENSE_ALREADY_ACCEPTED=1 apt-get install -y \
    /tmp/stm32cubeide/st-st*.deb && \
    rm -rf /tmp/stm32cubeide