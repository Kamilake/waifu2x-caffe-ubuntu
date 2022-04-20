FROM nvidia/cuda:11.4.0-cudnn8-runtime-ubuntu20.04
ARG SM = 86
RUN apt update && apt install -y   libboost-system-dev libboost-filesystem-dev libboost-thread-dev libopenblas-dev libboost-iostreams-dev libopenblas-dev
RUN git clone -b waifu2x-caffe-ubuntu https://github.com/kisaragychihaya/caffe /usr/src/lltcggie-caffe && \
  cd /usr/src/lltcggie-caffe && \
  cp Makefile.config.example-ubuntu Makefile.config && \
  sed -i 's/compute_35,code=sm_35/compute_61,code=sm_61/' Makefile.config && \
  sed -i 's/compute_50,code=sm_50/compute_75,code=sm_75 -gencode arch=compute_$SM,code=sm_$SM/' Makefile.config && \
  sed -i 's/-gencode arch=compute_50,code=compute_50/-gencode arch=compute_$SM,code=compute_$SM/' Makefile.config && \
  make -j
RUN git clone -b ubuntu https://github.com/nagadomi/waifu2x-caffe.git /usr/src/waifu2x-caffe && \
  cd /usr/src/waifu2x-caffe && \
  git submodule update --init --recursive && \
  ln -s ../lltcggie-caffe ./caffe && \
  ln -s ../lltcggie-caffe ./libcaffe && \
  rm -fr build # clean && \
  mkdir build && cd build &&\
  cmake .. -DCUDA_NVCC_FLAGS="-D_FORCE_INLINES  -gencode arch=compute_$SM,code=sm_$SM " && \
  make -j
RUN cd /usr/src/waifu2x-caffe/build && mv waifu2x-caffe /usr/local/bin/waifu2x-caffe && \
  mkdir -p /opt/libcaffe && mv libcaffe/lib/* /opt/libcaffe/ && echo /opt/libcaffe/ > /etc/ld.so.conf.d/caffe.conf && \
  ldconfig && cd .. && mv bin ../waifu2x && rm -rf /usr/src/waifu2x-caffe && rm -rf /usr/src/lltcggie-caffe && apt clean
RUN waifu2x-caffe --help
