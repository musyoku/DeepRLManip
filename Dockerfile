FROM nvidia/cuda:10.1-cudnn7-devel-ubuntu16.04

# mirror
RUN sed -i.bak -e "s%http://[^ ]\+%http://ftp.jaist.ac.jp/pub/Linux/ubuntu/%g" /etc/apt/sources.list

#==============================================================================
# OpenGL
#==============================================================================
RUN apt-get update && apt-get install -y --no-install-recommends pkg-config libxau-dev libxdmcp-dev libxcb1-dev libxext-dev libx11-dev && \
    rm -rf /var/lib/apt/lists/*

# replace with other Ubuntu version if desired
# see: https://hub.docker.com/r/nvidia/opengl/
COPY --from=nvidia/opengl:1.0-glvnd-runtime-ubuntu16.04 /usr/local/lib/x86_64-linux-gnu /usr/local/lib/x86_64-linux-gnu

# replace with other Ubuntu version if desired
# see: https://hub.docker.com/r/nvidia/opengl/
COPY --from=nvidia/opengl:1.0-glvnd-runtime-ubuntu16.04 /usr/local/share/glvnd/egl_vendor.d/10_nvidia.json /usr/local/share/glvnd/egl_vendor.d/10_nvidia.json

RUN echo '/usr/local/lib/x86_64-linux-gnu' >> /etc/ld.so.conf.d/glvnd.conf && \
    ldconfig && \
    echo '/usr/local/$LIB/libGL.so.1' >> /etc/ld.so.preload && \
    echo '/usr/local/$LIB/libEGL.so.1' >> /etc/ld.so.preload

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

# install GLX-Gears
RUN apt update && apt install -y --no-install-recommends mesa-utils x11-apps && rm -rf /var/lib/apt/lists/*

#==============================================================================
# OpenRAVE
#==============================================================================
RUN apt update && apt install -y cmake g++ git ipython minizip python-dev python-h5py python-numpy python-scipy python-sympy qt4-dev-tools
RUN apt update && apt install -y libassimp-dev libavcodec-dev libavformat-dev libavformat-dev libboost-all-dev libboost-date-time-dev libbullet-dev libfaac-dev libglew-dev libgsm1-dev liblapack-dev liblog4cxx-dev libmpfr-dev libode-dev libogg-dev libpcrecpp0v5 libpcre3-dev libqhull-dev libqt4-dev libsoqt-dev-common libsoqt4-dev libswscale-dev libswscale-dev libvorbis-dev libx264-dev libxml2-dev libxvidcore-dev

# collada-dom
RUN git clone https://github.com/rdiankov/collada-dom.git
RUN cd collada-dom && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j4 && \
    make install

# OpenSceneGraph
RUN apt update && apt install -y software-properties-common libcairo2-dev libjasper-dev libpoppler-glib-dev libsdl2-dev libtiff5-dev libxrandr-dev
RUN git clone --branch OpenSceneGraph-3.4 https://github.com/openscenegraph/OpenSceneGraph.git
RUN cd OpenSceneGraph && \
    mkdir build && \
    cd build && \
    cmake .. -DDESIRED_QT_VERSION=4 && \
    make -j4 && \
    make install

# Flexible Collision Library
RUN apt update && apt install -y libccd-dev
RUN git clone https://github.com/flexible-collision-library/fcl.git
RUN cd fcl && \
    git checkout 0.5.0 && \
    mkdir build && cd build && \
    cmake .. && \
    make -j4 && \
    make install

# OpenRAVE
RUN git clone --branch latest_stable https://github.com/rdiankov/openrave.git
RUN cd openrave && \
    git checkout 9c79ea260e1c009b0a6f7c03ec34f59629ccbe2c && \
    mkdir build && \
    cd build && \
    cmake .. -DOSG_DIR=/usr/local/lib64/ && \
    make -j4 && \
    make install

#==============================================================================
# DeepRLManip
#==============================================================================
RUN apt update && apt install -y python wget && \
    wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py && \
    pip install -U pip && pip install opencv-python scikit-image protobuf easydict cython
RUN apt update && apt install -y python python-numpy python-scipy python-matplotlib ipython ipython-notebook python-pandas python-sympy python-nose python-tk python-yaml build-essential cmake git pkg-config libprotobuf-dev libleveldb-dev libsnappy-dev libhdf5-serial-dev protobuf-compiler libatlas-base-dev libgflags-dev libgoogle-glog-dev liblmdb-dev libhdf5-dev curl && \
    rm -rf /var/lib/apt/lists/*

# OpenCV
RUN wget -O opencv-3.3.0.tar.gz https://github.com/opencv/opencv/archive/3.3.0.tar.gz && \
    tar zxvf opencv-3.3.0.tar.gz
RUN cd opencv-3.3.0 &&  \
    mkdir build && cd build && \
    cmake -D WITH_CUDA=OFF .. && make -j8 && make install

# PCL
RUN apt update && apt install -y linux-libc-dev libusb-1.0-0-dev libusb-dev libudev-dev mpi-default-dev openmpi-bin openmpi-common libflann1.8 libflann-dev libeigen3-dev libqhull* libgtest-dev freeglut3-dev pkg-config libxmu-dev libxi-dev mono-complete qt-sdk openjdk-8-jdk openjdk-8-jre libproj-dev libglfw3-dev libpcl-dev
RUN ln -s /usr/lib/x86_64-linux-gnu/libvtkCommonCore-6.2.so /usr/lib/libvtkproj4.so

# PointCloudsPython
RUN git clone https://github.com/mgualti/PointCloudsPython && \
    cd PointCloudsPython && \
    mkdir build && cd build && \
    cmake .. && \
    make -j8

# Caffe
RUN apt update && apt install -y libhdf5-dev
RUN git clone --recursive https://github.com/BVLC/caffe.git
RUN cd caffe && \
    cp Makefile.config.example Makefile.config && \
    echo "" >> Makefile.config && \
    echo "OPENCV_VERSION := 3" >> Makefile.config && \
    echo "PYTHON_INCLUDE := /usr/include/python2.7 /usr/local/lib/python2.7/dist-packages/numpy/core/include" >> Makefile.config && \
    echo "INCLUDE_DIRS := \$(PYTHON_INCLUDE) /usr/local/include /usr/include/hdf5/serial" >> Makefile.config && \
    echo "LIBRARY_DIRS := \$(PYTHON_LIB) /usr/local/lib /usr/lib /usr/lib/x86_64-linux-gnu/hdf5/serial" >> Makefile.config && \
    echo "CUDA_ARCH := -gencode arch=compute_30,code=sm_30 -gencode arch=compute_35,code=sm_35 -gencode arch=compute_50,code=sm_50 -gencode arch=compute_50,code=compute_50" >> Makefile.config && \
    make all -j8 && make pycaffe

RUN git clone https://github.com/mgualti/DeepRLManip && \
    cd DeepRLManip/extensions && \
    sh build.sh 

RUN wget --no-check-certificate https://strands.pdc.kth.se/public/3DNet_Dataset/Cat10_ModelDatabase.zip && \
    unzip Cat10_ModelDatabase.zip