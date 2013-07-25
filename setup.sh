#!/bin/bash

unknown_type=0
debian_type=1
redhat_type=2
system_type=$unknown_type
steps=1

# Determine type of system - yum based or apt-get based
if type apt-get > /dev/null; then
    echo "$steps. Debian type system detected"
    system_type=$debian_type
elif type yum > /dev/null; then
    echo "$steps. Redhat type system detected"
    system_type=$redhat_type
else
    echo "$steps. Unknown system - no apt-get, yum found"
    exit -1
fi
let "steps++"


# Begin yum based system bugs
# SSH takes a lot of time to prompt for password
if [ $system_type -eq $redhat_type ]; then
    echo "$steps. Fixing delayed SSH issue"
    sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bck
    sudo sed -i 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/g' /etc/ssh/sshd_config
    sudo service sshd restart
elif [ $system_type -eq $debian_type ]; then
    echo "$steps. No bugs"
fi
let "steps++"

# Install required common software
software="git screen vim vim-common rsync gcc mlocate unzip rlwrap"
echo "$steps. Installing $software"
if [ $system_type -eq $redhat_type ]; then
    sudo yum -y install $software
    sudo /etc/cron.daily/mlocate.cron
elif [ $system_type -eq $debian_type ]; then 
    sudo apt-get -y install $software
fi
let "steps++"

# Update file database
echo "$steps. Updating mlocate database"
sudo updatedb
let "steps++"


# Install specific software
echo "$steps. Installing fcgi and nginx"
if [ $system_type -eq $redhat_type ]; then
    sudo yum -y install http://epel.mirror.net.in/epel/6/x86_64/epel-release-6-8.noarch.rpm
    sudo yum -y install spawn-fcgi fcgi fcgi-devel
elif [ $system_type -eq $debian_type ]; then
    sudo apt-get -y install libfcgi-dev spawn-fcgi nginx curl
fi
let "steps++"


# Copy dotfiles
echo "$steps. Downloading and linking dotfiles"
cd $HOME
if [ -d ./dotfiles/ ]; then
    mv -f dotfiles dotfiles.old
fi
git clone https://github.com/nmunjal/dotfiles
ln -sb dotfiles/.screenrc .
ln -sb dotfiles/.bash_profile .
ln -sb dotfiles/.bashrc .
ln -sb dotfiles/.bashrc_custom .
let "steps++"


if [ $system_type -eq $redhat_type ]; then
    echo -n ""
elif [ $system_type -eq $debian_type ]; then 
    echo -n ""
fi
