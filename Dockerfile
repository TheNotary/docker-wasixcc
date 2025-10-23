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

# Install https://github.com/WebAssembly/wasi-sdk
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

#RUN wget -qO- https://apt.llvm.org/llvm.sh | bash -s -- 14


ENV LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:${LIBRARY_PATH}"
ENV PATH="/deps/binaryen/out/bin:${PATH}"

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
