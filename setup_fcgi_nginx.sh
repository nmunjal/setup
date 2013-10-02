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


# Install required common software
software="nginx"
echo "$steps. Installing $software"
if [ $system_type -eq $redhat_type ]; then
    sudo yum -y install $software
    sudo /etc/cron.daily/mlocate.cron
elif [ $system_type -eq $debian_type ]; then 
    sudo apt-get -y install $software
fi
let "steps++"


# Install specific software
echo "$steps. Installing spawn-fcgi"
if [ $system_type -eq $redhat_type ]; then
    sudo yum -y install http://epel.mirror.net.in/epel/6/x86_64/epel-release-6-8.noarch.rpm
    sudo yum -y install spawn-fcgi fcgi fcgi-devel gcc-c++ libmemcached-devel
elif [ $system_type -eq $debian_type ]; then
    sudo apt-get -y install libfcgi-dev spawn-fcgi g++ libmemcached-dev
fi
let "steps++"


# Update file database
echo "$steps. Updating mlocate database"
sudo updatedb
let "steps++"

# Installing libfcgi libraries
locate libfcgi.so 2>&1 >/dev/null
if [ $? -eq 0 ]; then
    echo "$steps. libfcgi already installed"
    exit 0
fi

cd /tmp/
rm  -rf fcgi.tar.gz fcgi
wget http://www.fastcgi.com/dist/fcgi.tar.gz
tar xvzf fcgi.tar.gz
cd fcgi-2.4.1-SNAP-0311112127/

# Apply patch
cd libfcgi/
cp -b fcgio.cpp fcgio.cpp.bck
patch --forward < ~/setup/fcgi_fix.patch
cd -
./configure && make
if [ $? -ne 0 ]; then
    exit -1
fi
sudo make install

