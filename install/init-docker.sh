#!/bin/bash

user=$USER
openenergymonitor_dir=/opt/openenergymonitor
emoncms_dir=/opt/emoncms

sudo apt-get update -y
sudo apt-get install -y git-core

sudo mkdir -p $openenergymonitor_dir
#sudo chown $user $openenergymonitor_dir

sudo mkdir -p $emoncms_dir
#sudo chown $user $emoncms_dir

cd $openenergymonitor_dir

git clone https://github.com/openenergymonitor/EmonScripts.git
cd $openenergymonitor_dir/EmonScripts
git checkout stable

cd $openenergymonitor_dir/EmonScripts/install

source load_config.sh

if [ "$apt_get_upgrade_and_clean" = true ]; then
    echo "apt-get update"
    sudo apt-get update -y
    echo "-------------------------------------------------------------"
    echo "apt-get upgrade"
    sudo apt-get upgrade -y
    echo "-------------------------------------------------------------"
    echo "apt-get dist-upgrade"
    sudo apt-get dist-upgrade -y
    echo "-------------------------------------------------------------"
    echo "apt-get clean"
    sudo apt-get clean

    # Needed on stock raspbian lite 19th March 2019
    sudo apt --fix-broken install
fi

# Required for backup, emonpiLCD, wifi, rfm69pi firmware (review)
if [ ! -d $openenergymonitor_dir/data ]; then mkdir $openenergymonitor_dir/data; fi

echo "-------------------------------------------------------------"
sudo apt-get install -y git build-essential python-pip python-dev gettext
echo "-------------------------------------------------------------"

if [ "$install_apache" = true ]; then $openenergymonitor_dir/EmonScripts/install/apache.sh; fi
if [ "$install_mysql" = true ]; then $openenergymonitor_dir/EmonScripts/install/mysql.sh; fi
if [ "$install_php" = true ]; then $openenergymonitor_dir/EmonScripts/install/php.sh; fi
if [ "$install_redis" = true ]; then $openenergymonitor_dir/EmonScripts/install/redis.sh; fi
if [ "$install_mosquitto" = true ]; then $openenergymonitor_dir/EmonScripts/install/mosquitto.sh; fi
if [ "$install_emoncms_core" = true ]; then $openenergymonitor_dir/EmonScripts/install/emoncms_core.sh; fi
if [ "$install_emoncms_modules" = true ]; then $openenergymonitor_dir/EmonScripts/install/emoncms_modules.sh; fi

if [ "$emonSD_pi_env" = "1" ]; then
    if [ "$install_emoncms_emonpi_modules" = true ]; then $openenergymonitor_dir/EmonScripts/install/emoncms_emonpi_modules.sh; fi
    if [ "$install_emonhub" = true ]; then $openenergymonitor_dir/EmonScripts/install/emonhub.sh; fi
    if [ "$install_firmware" = true ]; then $openenergymonitor_dir/EmonScripts/install/firmware.sh; fi
    if [ "$install_emonpilcd" = true ]; then $openenergymonitor_dir/EmonScripts/install/emonpilcd.sh; fi
    if [ "$install_wifiap" = true ]; then $openenergymonitor_dir/EmonScripts/install/wifiap.sh; fi
    if [ "$install_emonsd" = true ]; then $openenergymonitor_dir/EmonScripts/install/emonsd.sh; fi

    # Enable service-runner update
    # update checks for image type and only runs with a valid image name file in the boot partition
    sudo touch /boot/emonSD-02Oct19
    exit 0
    # Reboot to complete
    sudo reboot
else
    $openenergymonitor_dir/EmonScripts/install/non_emonsd.sh;
    # sudo touch /boot/emonSD-30Oct18
    exit 0
    # Reboot to complete
    sudo reboot
fi


rm init.sh
