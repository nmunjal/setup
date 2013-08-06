#!/bin/bash

unknown_type=0
debian_type=1
redhat_type=2
system_type=$unknown_type
steps=1


# Determine type of system - yum based or apt-get based
if type apt-get > /dev/null; then
    echo "$steps. Debian type system detected"
    sudo apt-get update
    sudo apt-get upgrade
    system_type=$debian_type
elif type yum > /dev/null; then
    echo "$steps. Redhat type system detected"
    sudo yum update
    system_type=$redhat_type
else
    echo "$steps. Unknown system - no apt-get, yum found"
    exit -1
fi
let "steps++"

# Install specific software
echo "$steps. Installing g++"
if [ $system_type -eq $redhat_type ]; then
    sudo yum -y install http://epel.mirror.net.in/epel/6/x86_64/epel-release-6-8.noarch.rpm
    sudo yum -y install python-devel libevent-devel
elif [ $system_type -eq $debian_type ]; then
    sudo apt-get -y install python-dev libevent-dev libzmq-dev
fi
let "steps++"

pip="pip"
type python-pip > /dev/null 2>&1
if [ $? -eq 0 ]; then
    pip="python-pip"
fi
sudo $pip install locustio

sudo updatedb
locate libzmq.so
if [ $? -ne 0 ]; then
    cd /tmp/
    rm zeromq-3.2.3* -rf
    wget http://download.zeromq.org/zeromq-3.2.3.tar.gz
    tar xvzf zeromq-3.2.3.tar.gz
    cd zeromq-3.2.3
    ./configure && make
    if [ $? -eq 0 ]; then
        sudo make install
    else
        exit -1
    fi
fi
sudo $pip install gevent-zeromq

cd /tmp/
rm -rf pyzmq*
wget https://github.com/downloads/zeromq/pyzmq/pyzmq-2.2.0.tar.gz
tar xvzf pyzmq-2.2.0.tar.gz
cd pyzmq-2.2.0
sudo python setup.py install

sudo $pip install zmqrpc
