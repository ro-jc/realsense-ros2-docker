# Use ROS 2 Foxy desktop as the base image
FROM osrf/ros:foxy-desktop

# Install colcon and necessary dependencies
# RUN apt-get update && apt-get install -y \
#     python3-colcon-common-extensions \
#     build-essential \
#     && rm -rf /var/lib/apt/lists/*

# Create a workspace directory
RUN apt-get update && apt-get install -y \
    software-properties-common \
    && apt-get update && apt-get install -y \
    git \
    build-essential \
    cmake \
    sudo \
    curl \
    wget \
    ninja-build \
    wayland-protocols \
    libc++-dev \
    libepoxy-dev \
    libavcodec-dev \
    libavformat-dev \
    libavutil-dev \
    libavdevice-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy entrypoint script for environment setup
COPY ./entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh

RUN git clone https://github.com/catchorg/Catch2.git

RUN cd Catch2 &&  \
    cmake -Bbuild -H. -DBUILD_TESTING=OFF && \
    sudo cmake --build build/ --target install 


RUN git clone https://github.com/stevenlovegrove/Pangolin

RUN cd Pangolin && cmake -B build \
    -DCATCH2_DIR=/usr/local/lib/cmake/Catch2

RUN cd Pangolin && \
     cmake --build build -j$(nproc) && \
     sudo cmake --install build


RUN git clone https://github.com/yashas3013/ORB-SLAM3-STEREO-FIXED.git ORB_SLAM3
RUN cd ORB_SLAM3 && chmod +x build.sh && /bin/bash -c "./build.sh"
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/ORB_SLAM3/lib
RUN ldconfig

WORKDIR /root/ros2_ws

# Default to bash and source ROS 2 environment
ENTRYPOINT ["/root/entrypoint.sh"]

