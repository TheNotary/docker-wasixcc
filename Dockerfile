FROM debian:bookworm

################
#  System Deps #
################

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
  apt-get install -y git cmake build-essential ninja-build clang \
                     ca-certificates curl gnupg lsb-release \
                     pkg-config libssl-dev wget software-properties-common libpcre3-dev libz-dev autoconf gcc-multilib \
                     vim \
  && rm -rf /var/lib/apt/lists/*


#######################################################
# Install https://github.com/WebAssembly/binaryen.git #
#######################################################
#
# This gives you a bunch of wasm related tools
#

WORKDIR /deps
RUN git clone https://github.com/WebAssembly/binaryen.git
WORKDIR /deps/binaryen
RUN git submodule init
RUN git submodule update
RUN mkdir -p out

RUN cmake -S . -B out -G Ninja -DCMAKE_INSTALL_PREFIX=out/install -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DBUILD_FUZZTEST=ON

RUN cmake --build out --config Release -v

RUN curl  --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

RUN wget -qO- https://apt.llvm.org/llvm.sh | bash -s -- 21

ENV PATH="/root/.cargo/bin:${PATH}"
RUN cargo install wasixcc -F bin

RUN wasixcc --install-executables /usr/local/bin
RUN wasixcc --download-all

###################################################
# Install https://github.com/WebAssembly/wasi-sdk #
###################################################
#
# This gives you a clang and other misc bins in /wasi-bin with wasm support.
# It gives you a sysroot, but it might be too weak?
#

WORKDIR /wasi-bin

ENV WASI_OS=linux
ENV WASI_ARCH=x86_64
ENV WASI_VERSION=27
ENV WASI_VERSION_FULL=${WASI_VERSION}.0
RUN wget https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-${WASI_VERSION}/wasi-sdk-${WASI_VERSION_FULL}-${WASI_ARCH}-${WASI_OS}.tar.gz
RUN tar xvf wasi-sdk-${WASI_VERSION_FULL}-${WASI_ARCH}-${WASI_OS}.tar.gz --strip-components=1

ENV WASI_SDK_PATH=/wasi-bin
ENV CLANGCC="${WASI_SDK_PATH}/bin/clang --sysroot=${WASI_SDK_PATH}/share/wasi-sysroot"

# /wasi-bin/bin/clang --sysroot=/wasi-bin/share/wasi-sysroot


#RUN apt-get install -y lld-14 wabt libc-dev llvm-14
#RUN apt-get install -y lld-14 wabt libc-dev llvm-14
RUN apt-get install -y apt-file
RUN apt-file update

RUN apt-get install -y bash-builtins

#RUN wget -qO- https://apt.llvm.org/llvm.sh | bash -s -- 14

####################################################
# Install https://github.com/WebAssembly/wasi-libc #
####################################################
#
# This gives you a sysroot that clang can use which gives you a ton of headers
# and the ability to build for the wasm target.
#
# I think we want wasmer's fork though?
#

WORKDIR /wasi-libc
RUN git clone https://github.com/WebAssembly/wasi-libc
WORKDIR /wasi-libc/wasi-libc
RUN make \
     CC=/wasi-bin/bin/clang \
     AR=/wasi-bin/bin/llvm-ar \
     NM=/wasi-bin/bin/llvm-nm



ENV LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:${LIBRARY_PATH}"
ENV PATH="/deps/binaryen/out/bin:${PATH}"
ENV PATH="/wasi-bin/bin:${PATH}"

ENV OPENSSL_LIB_DIR="/usr/lib/x86_64-linux-gnu"
ENV OPENSSL_INCLUDE_DIR="/usr/include/openssl"
ENV OPENSSL_LINK="/usr/include/openssl"
ENV OPENSSL_LIBSSL="/usr/lib/x86_64-linux-gnu"

ENV CC=wasixcc
ENV CXX=wasix++
ENV LD=wasixld
ENV AR=wasixar
ENV NM=wasixnm
ENV RANLIB=wasixranlib


# When done developing this dockerfile, make sure you clean up
# the apt-get junk for production
#RUN apt-get clean


################
#  App Deps    #
################

# TODO:
# Copy over your application stuff required to load up
# dependencies and then install those dependencies



################
#  App Source  #
################

# TODO:
# Copy over your apps sourcecode in this section



#############
#  Conclude #
#############

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod +x /sbin/entrypoint.sh
RUN echo ". /sbin/entrypoint.sh" > /root/.bash_history
WORKDIR /app

ENTRYPOINT ["/sbin/entrypoint.sh"]
