#!/bin/bash

echo "FROM buildpack-deps:$(awk -F'_' '{print tolower($2)}' <<< $LINUX_VERSION)"

echo "RUN apt-get update"

echo "RUN apt-get install -y gperf flex bison build-essential clang tcl-dev libboost-dev libfl-dev zlibc zlib1g zlib1g-dev perl git ccache libgoogle-perftools-dev numactl perl-doc python3"

echo "RUN python -V"

echo "RUN python3 -V"

# echo "RUN sudo apt-get install -y make build-essential libssl-dev zlib1g-dev \
   # libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev\
   # libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python-openssl\
   # git"

# echo "RUN pyenv versions"

# echo "RUN pyenv install 3.8.5"

# echo "RUN pyenv global 3.8.5"

echo "RUN git clone https://github.com/verilator/verilator && cd verilator && git checkout v4.218 && autoconf && ./configure && make && make install"

echo "RUN wget ftp://ftp.icarus.com/pub/eda/verilog//v11/verilog-11.0.tar.gz && tar -xzvf verilog-11.0.tar.gz && \
    cd verilog-11.0 && ./configure && make && make install"
# echo "RUN apt-get install -y iverilog"
# echo "RUN apt-get install -y verilator"
# echo "RUN apt-get install -y yosys"

if [ ! -e $PYTHON_VERSION_NUM ] ; then
    echo "RUN wget https://www.python.org/ftp/python/$PYTHON_VERSION_NUM/Python-$PYTHON_VERSION_NUM.tgz && \
    tar xzf Python-$PYTHON_VERSION_NUM.tgz && \
    rm Python-$PYTHON_VERSION_NUM.tgz && \
    cd Python-$PYTHON_VERSION_NUM && \
    ./configure && \
    make install"
fi

echo "RUN wget https://github.com/YosysHQ/yosys/archive/refs/tags/yosys-0.15.tar.gz && tar -xf yosys-0.15.tar.gz && cd yosys-yosys-0.15 && \
    make && \
    make install"

# if [ ! -e $PHP_VERSION_NUM ] ; then
#     wget "http://php.net/distributions/php-${PHP_VERSION_NUM}.tar.xz"
# fi

if [ $JAVA = "true" ] ; then
cat << EOF
RUN if [ \$(grep 'VERSION_ID="8"' /etc/os-release) ] ; then \\
    echo "deb http://ftp.debian.org/debian jessie-backports main" >> /etc/apt/sources.list && \\
    apt-get update && apt-get -y install -t jessie-backports openjdk-8-jdk ca-certificates-java \\
; elif [ \$(grep 'VERSION_ID="9"' /etc/os-release) ] ; then \\
		apt-get update && apt-get -y -q --no-install-recommends install -t stable openjdk-8-jdk ca-certificates-java \\
; elif [ \$(grep 'VERSION_ID="14.04"' /etc/os-release) ] ; then \\
		apt-get update && \\
    apt-get --force-yes -y install software-properties-common python-software-properties && \\
    echo | add-apt-repository -y ppa:webupd8team/java && \\
    apt-get update && \\
    echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \\
    echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections && \\
    apt-get -y install oracle-java8-installer \\
; elif [ \$(grep 'VERSION_ID="16.04"' /etc/os-release) ] ; then \\
    apt-get update && \\
    apt-get --force-yes -y install software-properties-common python-software-properties && \\
    echo | add-apt-repository -y ppa:webupd8team/java && \\
    apt-get update && \\
    echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \\
    echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections && \\
    apt-get -y install oracle-java8-installer \\
; fi
EOF
fi

if [ $DOCKERIZE = "true" ] ; then
DOCKERIZE_VERSION="v0.6.1"

cat << EOF
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz && \\
    tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz && \\
    rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz
EOF
fi

# install bats for testing
echo "RUN git clone https://github.com/sstephenson/bats.git \
  && cd bats \
  && ./install.sh /usr/local \
  && cd .. \
  && rm -rf bats"

# install dependencies for tap-to-junit
echo "RUN perl -MCPAN -e 'install TAP::Parser'"
echo "RUN perl -MCPAN -e 'install XML::Generator'"

# install lsb-release, etc., for testing linux distro
echo "RUN apt-get update && apt-get -y install lsb-release unzip"
