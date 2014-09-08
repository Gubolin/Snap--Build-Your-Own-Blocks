#!/bin/bash

if [[ $1 = "" ]]
then
    echo "Usage: mobile.sh PLATFORM [BUILDSOURCE]"
    exit 0
fi

scriptdir=$(readlink -e ".")

# Requirements:
# git, nodejs, android SDK / other platform(s)
# cordova (https://cordova.apache.org/)

if [[ $2 != "" ]]
then
    buildsource=$(readlink -e "$2")
fi

builddir=$(mktemp -d)

cordova create $builddir edu.berkeley.snap "Snap\!"
cd $builddir
rm -rf www config.xml

if [[ $2 == "" ]]
then
    git clone https://github.com/Gubolin/snap.git www
    cd www/
    git checkout mobileapp
else
    mv "$buildsource" www
    cd www
fi

# remove configs for desktop, it is not needed
rm package.json

# add mobile-specific library; it's made available at runtime
sed -i '/link rel="shortcut icon"/a\
        <script type="text/javascript" src="cordova.js"></script>' snap.html

# add everything needed and build for $device
cordova platform add "$1"
cordova plugin add org.apache.cordova.plugin.softkeyboard
cordova plugin add org.apache.cordova.vibration
cordova plugin add org.apache.cordova.device-motion
cordova plugin add org.apache.cordova.device-orientation
cordova plugin add org.apache.cordova.geolocation
cordova build "$1"

cd $builddir
# TODO other platforms
find -name '*.apk' | xargs -I {} mv {} $scriptdir
