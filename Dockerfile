#FROM nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04
FROM nvcr.io/nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04
ENV DEBIAN_FRONTEND "noninteractive"

RUN apt-get update -y
RUN apt-get -y \
  -o Dpkg::Options::="--force-confdef" \
  -o Dpkg::Options::="--force-confold" dist-upgrade

RUN apt-get install -y --no-install-recommends \
  dconf-tools \
  curl wget \
  tar zip unzip zlib1g-dev bzip2 libbz2-dev \
  openssl libssl-dev \
  zsh vim screen tree htop \
  net-tools lynx iftop traceroute \
  git apt-transport-https software-properties-common ppa-purge apt-utils ca-certificates \
  build-essential binutils cmake pkg-config libtool autoconf automake autogen \
  sudo

RUN add-apt-repository ppa:ubuntu-toolchain-r/test
RUN apt-get update -y
RUN apt-get install -y --no-install-recommends \
  gcc-6 g++-6 gcc-7 g++-7 gdb
#RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-6 20
#RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-6 20

RUN apt-get install -y --no-install-recommends \
  libboost-all-dev \
  libtbb2 libtbb-dev \
  libatlas-base-dev libopenblas-base libopenblas-dev \
  libeigen3-dev liblapacke-dev \
  graphviz

RUN apt-get install -y --no-install-recommends \
  python-dev python-pip python-setuptools \
  python3-dev python3-pip python3-setuptools \
  python-numpy

RUN apt-get install -y --no-install-recommends \
  libprotobuf-dev libleveldb-dev libsnappy-dev libhdf5-serial-dev libhdf5-dev protobuf-compiler liblmdb-dev \
  libgflags-dev \
  libgoogle-glog-dev

RUN apt-get install -y --no-install-recommends \
  yasm \
  ffmpeg libavcodec-dev libavformat-dev libswscale-dev libavresample-dev libxine2-dev \
  libdc1394-22 libdc1394-22-dev libjpeg-dev libpng12-dev libtiff5-dev libjasper-dev \
  libv4l-dev libfaac-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libtheora-dev libvorbis-dev libxvidcore-dev v4l-utils


RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get dist-upgrade -y
RUN apt-get clean
RUN apt-get autoremove -y
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get autoremove -y
RUN apt-get autoclean -y
RUN rm -rf /var/lib/apt/lists/*

WORKDIR /opt
RUN wget https://github.com/Itseez/opencv/archive/3.4.0.zip -O opencv-3.4.0.zip
RUN unzip opencv-3.4.0.zip
RUN mkdir -p /opt/opencv-3.4.0/build
WORKDIR /opt/opencv-3.4.0/build
RUN  cmake \
  -DCMAKE_BUILD_TYPE=RELEASE \
  -DBUILD_DOCS=OFF \
  -DBUILD_EXAMPLES=OFF \
  -DBUILD_TESTS=OFF \
  -DBUILD_PERF_TESTS=OFF \
  -DBUILD_WITH_DEBUG_INFO=OFF \
  -DBUILD_SHARED_LIBS=ON \
  -DBUILD_OPENCV_WORLD=OFF \
  -DBUILD_OPENCV_DNN=OFF \
  -DBUILD_opencv_nonfree=ON \
  -DBUILD_OPENCV_PYTHON=ON \
  -DBUILD_OPENCV_PYTHON2=OFF \
  -DBUILD_OPENCV_PYTHON3=ON \
  -DBUILD_NEW_PYTHON_SUPPORT=ON \
  -DWITH_OPENGL=ON \
  -DWITH_OPENCL=ON \
  -DWITH_TBB=ON \
  -DWITH_EIGEN=ON \
  -DWITH_FFMPEG=ON \
  -DWITH_GSTREAMER=OFF \
  -DWITH_V4L=ON \
  -DWITH_OPENGL=ON \
  -DWITH_OPENCL=ON \
  -DWITH_CUDA=ON \
  -DWITH_CUBLAS=ON \
  -DWITH_NVCUVID=ON \
  -DWITH_CUFFT=ON \
  -DCUDA_FAST_MATH=ON \
  -DWITH_EIGEN=ON \
  -DWITH_TBB=ON \
  -DWITH_PTHREADS_PF=ON \
  -DWITH_IPP=ON \
  -DENABLE_PRECOMPILED_HEADERS=ON \
  -DENABLE_FAST_MATH=ON \
  ..
#  -DENABLE_CXX11=ON \
#  -DCXXFLAGS="-std=c++14" \
#  -DCUDA_NVCC_FLAGS="-std=c++11 --expt-relaxed-constexpr" \
RUN make -j && make install




WORKDIR /opt
RUN git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose

WORKDIR /opt/openpose/3rdparty/caffe/
RUN cp Makefile.config.Ubuntu16_cuda8.example Makefile.config
RUN echo "OPENCV_VERSION := 3" >>Makefile.config
RUN make all -j${number_of_cpus}
RUN make distribute -j${number_of_cpus}
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/openpose/3rdparty/caffe/distribute/lib
RUN ldconfig

WORKDIR /opt/openpose
COPY openpose-mp4.patch ./
RUN patch -p1 < openpose-mp4.patch
RUN cp ubuntu/Makefile.config.Ubuntu16_cuda8.example Makefile.config
RUN echo "OPENCV_VERSION := 3" >>Makefile.config
RUN make all -j${number_of_cpus}

WORKDIR /opt/openpose/models/
RUN bash ./getModels.sh

WORKDIR /opt/openpose



