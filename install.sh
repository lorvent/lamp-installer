#!/bin/bash
SSH_PORT="22"
#DB_PASSWORD="database_password"
#DB_NAME="database_name"
#DB_USER="database_user"
#DB_USER_PASSWORD="database_user_password"



###########################################################
# Functions
###########################################################

#---- Update system once before we start our operations

function system_update {
    apt-get update
    apt-get -y upgrade
}

function mysql_tune {
    # Tunes MySQL's memory usage to utilize the percentage of memory you specify, defaulting to 40%

    # $1 - the percent of system memory to allocate towards MySQL

    if [ ! -n "$1" ];
        then PERCENT=40
        else PERCENT="$1"
    fi

    sed -i -e 's/^#skip-innodb/skip-innodb/' /etc/mysql/my.cnf # disable innodb - saves about 100M

    MEM=$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo) # how much memory in MB this system has
    MYMEM=$((MEM*PERCENT/100)) # how much memory we'd like to tune mysql with
    MYMEMCHUNKS=$((MYMEM/4)) # how many 4MB chunks we have to play with

    # mysql config options we want to set to the percentages in the second list, respectively
    OPTLIST=(key_buffer sort_buffer_size read_buffer_size read_rnd_buffer_size myisam_sort_buffer_size query_cache_size)
    DISTLIST=(75 1 1 1 5 15)

    for opt in ${OPTLIST[@]}; do
        sed -i -e "/\[mysqld\]/,/\[.*\]/s/^$opt/#$opt/" /etc/mysql/my.cnf
    done

    for i in ${!OPTLIST[*]}; do
        val=$(echo | awk "{print int((${DISTLIST[$i]} * $MYMEMCHUNKS/100))*4}")
        if [ $val -lt 4 ]
            then val=4
        fi
        config="${config}\n${OPTLIST[$i]} = ${val}M"
    done

    sed -i -e "s/\(\[mysqld\]\)/\1\n$config\n/" /etc/mysql/my.cnf

    touch /tmp/restart-mysql
}


#---- Restart services

function restartServices {
    # restarts services that have a file in /tmp/needs-restart/

    for service in $(ls /tmp/restart-* | cut -d- -f2-10); do
        /etc/init.d/$service restart
        rm -f /tmp/restart-$service
    done
}



###########################################################
# Command stuffs
###########################################################


#install some image libraries needed for image-min
npm install -g jpegtran-bin gifsicle optipng-bin

#install phantomjs
sudo curl --output /usr/local/bin/phantomjs https://s3.amazonaws.com/circle-downloads/phantomjs-2.1.1
chmod +x /usr/local/bin/phantomjs


#----- install linux-dash and virtualhost, letsencrypt
cd /var/www/html
git clone https://github.com/afaqurk/linux-dash.git
git clone https://github.com/letsencrypt/letsencrypt.git
git clone https://github.com/lorvent/virtualhost
cd virtualhost
chmod +x virtualhost.sh
cp virtualhost.sh /usr/local/bin/virtualhost
cd $cwd


# Install redis etc advanced ones (for deployer)
apt-get install -y redis-server memcached beanstalkd

# Configure Beanstalkd
sed -i "s/#START=yes/START=yes/" /etc/default/beanstalkd
/etc/init.d/beanstalkd start

# Enable Swap Memory
/bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=1024
/sbin/mkswap /var/swap.1
/sbin/swapon /var/swap.1

#---- install oh-my-zsh
chsh -s $(which zsh)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

#--- cleanup
apt-get autoremove


#---- Restart everything
restartServices
