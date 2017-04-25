## Note: Our Caffe version does not work with CuDNN 6
FROM nvidia/cuda:8.0-cudnn5-devel-ubuntu16.04

## Hardcoded driver version, feel free to test another version!
ENV CUDA_DRIVER_VER="367.57"
ENV CUDA_DRIVER_RUN="NVIDIA-Linux-x86_64-${CUDA_DRIVER_VER}.run" 
ENV DISPNET_TAR="dispflownet-release-docker.tar.gz"

## Put everything in some subfolder
WORKDIR "/dispflownet"

## Container's mount point for the host's input/output folder
VOLUME "/input-output"

## 1. Install packages
## 2. Download and install CUDA driver
## 3. Download and build DispNet/FlowNet Caffe distro
## 4. Remove some now unused packages and clean up (for a smaller image)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        module-init-tools \
        build-essential \
        wget \
        libatlas-base-dev \
        libboost-all-dev \
        libgflags-dev \
        libgoogle-glog-dev \
        libhdf5-serial-dev \
        libleveldb-dev \
        liblmdb-dev \
        libopencv-dev \
        libprotobuf-dev \
        libsnappy-dev \
        protobuf-compiler \
        python-dev \
        python-numpy \
        python-scipy && \
\
    wget --progress=bar:force:noscroll http://us.download.nvidia.com/XFree86/Linux-x86_64/${CUDA_DRIVER_VER}/${CUDA_DRIVER_RUN} && \
    bash $CUDA_DRIVER_RUN -s -N --no-kernel-module && \
    rm $CUDA_DRIVER_RUN && \
\
    wget --progress=bar:force:noscroll --no-check-certificate https://lmb.informatik.uni-freiburg.de/data/${DISPNET_TAR} && \
    tar xfz ${DISPNET_TAR} && \
    rm ${DISPNET_TAR} && \
    cd dispflownet-release && \
    make -j`nproc` && \
\
    apt-get remove -y \
        module-init-tools \
        build-essential \
        wget && \
    apt-get autoremove -y && \
    apt-get autoclean -y && \
    rm -rf /var/lib/apt/lists/*
