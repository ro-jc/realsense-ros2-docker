ARG BASE_IMAGE=ros:foxy

# The following steps are based on the offical multi-stage build: https://github.com/IntelRealSense/librealsense/blob/master/scripts/Docker/Dockerfile
#################################
#   Librealsense Builder Stage  #
#################################
FROM $BASE_IMAGE as librealsense-builder

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -qq -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    libssl-dev \
    libusb-1.0-0-dev \
    pkg-config \
    libgtk-3-dev \
    libglfw3-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    curl \
    python3 \
    python3-dev \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src
# Get the latest tag of remote repository: https://stackoverflow.com/a/12704727
# Needs to be a single command as ENV can't be set from Bash command: https://stackoverflow.com/questions/34911622/dockerfile-set-env-to-result-of-command
RUN export LIBRS_GIT_TAG=v2.50.0;\
    export LIBRS_VERSION=${LIBRS_VERSION:-${LIBRS_GIT_TAG#"v"}}; \
    curl https://codeload.github.com/IntelRealSense/librealsense/tar.gz/refs/tags/v${LIBRS_VERSION} -o librealsense.tar.gz; \
    tar -zxf librealsense.tar.gz; \
    rm librealsense.tar.gz; \
    ln -s /usr/src/librealsense-${LIBRS_VERSION} /usr/src/librealsense

RUN cd /usr/src/librealsense \
 && mkdir build && cd build \
 && cmake \
    -DCMAKE_C_FLAGS_RELEASE="${CMAKE_C_FLAGS_RELEASE} -s" \
    -DCMAKE_CXX_FLAGS_RELEASE="${CMAKE_CXX_FLAGS_RELEASE} -s" \
    -DCMAKE_INSTALL_PREFIX=/opt/librealsense \    
    -DBUILD_GRAPHICAL_EXAMPLES=OFF \
    -DBUILD_PYTHON_BINDINGS:bool=true \
    -DCMAKE_BUILD_TYPE=Release  \
    -DFORCE_RSUSB_BACKEND=TRUE ../ \
 && make -j$(($(nproc)-1)) all \
 && make install

ENV DEBIAN_FRONTEND=dialog

######################################
#   librealsense Base Image Stage    #
######################################
FROM ${BASE_IMAGE} as librealsense

SHELL ["/bin/bash", "-c"]

COPY --from=librealsense-builder /opt/librealsense /usr/local/
COPY --from=librealsense-builder /usr/lib/python3/dist-packages/pyrealsense2 /usr/lib/python3/dist-packages/pyrealsense2
COPY --from=librealsense-builder /usr/src/librealsense/config/99-realsense-libusb.rules /etc/udev/rules.d/
ENV PYTHONPATH=${PYTHONPATH}:/usr/local/lib

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y --no-install-recommends \	
    libusb-1.0-0 \
    udev \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
 && rm -rf /var/lib/apt/lists/*

# The following steps are based on: https://github.com/IntelRealSense/realsense-ros/tree/ros2-development
ENV WS_DIR="/ros2_ws"
WORKDIR ${WS_DIR}
RUN apt-get update -y \
 && apt-get install -y \
    ros-${ROS_DISTRO}-rviz2 \
    ros-${ROS_DISTRO}-xacro \
    ros-${ROS_DISTRO}-diagnostic-updater \
    ros-${ROS_DISTRO}-image-transport \
    ros-${ROS_DISTRO}-cv-bridge \
    wget \
 && mkdir src \
 && cd src \
# && git clone https://github.com/IntelRealSense/realsense-ros.git -b ros2-development \
 && wget "https://github.com/IntelRealSense/realsense-ros/archive/refs/tags/4.0.4.tar.gz" \
 && tar xzf *.tar.gz \
 && cd .. \
 && apt-get install -y python3-rosdep

RUN echo ROS_DISTRO: $ROS_DISTRO \
 && source /opt/ros/${ROS_DISTRO}/setup.bash \
 && rm /etc/ros/rosdep/sources.list.d/20-default.list \
 && rosdep init \
 && rosdep update \
 && rosdep install -i --from-paths src --include-eol-distros --rosdistro ${ROS_DISTRO} --skip-keys=librealsense2 -y \
 && colcon build

RUN echo 'SUBSYSTEM=="usb", ATTRS{idVendor}=="8086", ATTRS{idProduct}=="0b3a", MODE="0666", GROUP="plugdev"' \
 >> /etc/udev/rules.d/99-realsense-camera.rules

RUN apt-get update && apt-get install -y \
    kmod \
    libudev-dev

RUN sudo apt-get install -y usbutils hwdata

ENV DEBIAN_FRONTEND=dialog

#CMD [ "rs-enumerate-devices", "--compact" ]
CMD [ "/bin/bash", "-c", "source /opt/ros/${ROS_DISTRO}/setup.bash && source ${WS_DIR}/install/setup.bash && ros2 launch realsense2_camera rs_launch.py /camera:=/t265" ]
