#!/bin/bash
# Ubuntu Developer Script For Ionic Framework
# Created by Nic Raboy
# http://www.nraboy.com
# And modified/updated by zebus (16/01/2016) www.my-geek-site.dx.am
#
# Downloads and configures the following:
#
#   Java JDK
#   Apache Ant
#   Android
#   NPM
#   Apache Cordova
#   Ionic Framework
#   git

clear
 
#HOME_PATH=$(cd ~/ && pwd)
HOME_PATH=$HOME
INSTALL_PATH=/opt
ANDROID_SDK_PATH=/opt/android-sdk
NODE_PATH=/opt/node
 
# x86_64 or i686
#LINUX_ARCH="$(lscpu | grep 'Architecture' | awk -F\: '{ print $2 }' | tr -d ' ')"
LINUX_ARCH=$(uname -m)
 
# Latest Android Linux SDK for x64 and x86 as of 16-01-2016
#ANDROID_SDK_X64="http://dl.google.com/android/android-sdk_r23.0.2-linux.tgz"
ANDROID_SDK_X64="http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz"
#ANDROID_SDK_X86="http://dl.google.com/android/android-sdk_r23.0.2-linux.tgz"
ANDROID_SDK_X86="http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz"
 
# Latest NodeJS for x64 and x86 as of 16-01-2016
#NODE_X64="http://nodejs.org/dist/v0.10.32/node-v0.10.32-linux-x64.tar.gz"
NODE_X64="https://nodejs.org/dist/v4.2.4/node-v4.2.4-linux-x64.tar.gz"
#NODE_X86="http://nodejs.org/dist/v0.10.32/node-v0.10.32-linux-x86.tar.gz"
NODE_X86="https://nodejs.org/dist/v4.2.4/node-v4.2.4-linux-x86.tar.xz"
 

NODE_FOLDER="node-v4.2.4-linux-x64"
NODE_FOLDER86="node-v4.2.4-linux-x86"
ANDROID_FOLDER="android-sdk-linux"

# Update all Ubuntu software repository lists
echo "now sudo apt-get update:"
sudo apt-get update
 
#echo $USER
#WGET_DEST="$HOME/Desktop"
WGET_DEST="/tmp"
cd $WGET_DEST
 
if [ "$LINUX_ARCH" == "x86_64" ]; then
    if [ ! -f "$WGET_DEST/nodejs.tgz" ]; then
        echo "x86_64 Downloading $NODE_X64..." 
        wget "$NODE_X64" -O "$WGET_DEST/nodejs.tgz"
    fi
    if [ ! -f "$WGET_DEST/android-sdk.tgz" ]; then
        echo "x86_64 Downloading $ANDROID_SDK_X64..."
        wget "$ANDROID_SDK_X64" -O "$WGET_DEST/android-sdk.tgz"
    fi
    if [ ! -d "$NODE_FOLDER" ]; then
        echo "Decompressing nodejs in /opt "
        sudo tar zxvf "nodejs.tgz" -C "$INSTALL_PATH" 
    fi
    if [ ! -d "$ANDROID_FOLDER" ]; then
        echo "Decompressing android-sdk in /opt"
        sudo tar zxvf "android-sdk.tgz" -C "$INSTALL_PATH" 
    fi

    # if already renamed, dont show errors ( 2>/dev/null )
    cd "$INSTALL_PATH" && sudo mv "$ANDROID_FOLDER" "android-sdk" 2>/dev/null
    #cd "$INSTALL_PATH" && mv "node-v0.10.32-linux-x64" "node"
    cd "$INSTALL_PATH" && sudo mv "$NODE_FOLDER" "node" 2>/dev/null
 
    # Android SDK requires some x86 architecture libraries even on x64 system
    sudo apt-get install -qq -y libc6:i386 libgcc1:i386 libstdc++6:i386 libz1:i386
 
else
    if [ ! -f "$WGET_DEST/nodejs.tgz" ]; then
        echo "i386 Downloading $NODE_X86..."
        wget "$NODE_X86" -O "$WGET_DEST/nodejs.tgz"
    fi
    if [ ! -f "$WGET_DEST/android-sdk.tgz" ]; then
        echo "i386 Downloading $ANDROID_SDK_X86..."
        wget "$ANDROID_SDK_X86" -O "$WGET_DEST/android-sdk.tgz"
    fi
    if [ ! -d "$NODE_FOLDER86" ]; then
        echo "Decompressing nodejs in /opt" 
        sudo tar zxvf "nodejs.tgz" -C "$INSTALL_PATH"
    fi
    if [ ! -d "$ANDROID_FOLDER" ]; then
        echo "Decompressing android-sdk in /opt"
        sudo tar zxvf "android-sdk.tgz" -C "$INSTALL_PATH"
    fi

    # if already renamed, dont show errors ( 2>/dev/null )
    cd "$INSTALL_PATH" && sudo mv "$ANDROID_FOLDER" "android-sdk" 2>/dev/null
    #cd "$INSTALL_PATH" && mv "node-v0.10.32-linux-x86" "node"
    cd "$INSTALL_PATH" && sudo mv "$NODE_FOLDER86" "node" 2>/dev/null
 
fi
 
cd "$INSTALL_PATH" && sudo chown $USER:$USER -R "android-sdk"
cd "$INSTALL_PATH" && sudo chmod -R 754 "android-sdk"
 
cd $HOME
 
# Add Android and NPM paths to the profile to preserve settings on boot
echo "export PATH=\"\$PATH:$ANDROID_SDK_PATH/tools\"" >> ".profile"
echo "export PATH=\"\$PATH:$ANDROID_SDK_PATH/platform-tools\"" >> ".profile"
echo "export PATH=\"\$PATH:$NODE_PATH/bin\"" >> ".profile"
 
# Add Android and NPM paths to the temporary user path to complete installation
export PATH=$PATH:$ANDROID_SDK_PATH/tools
export PATH=$PATH:$ANDROID_SDK_PATH/platform-tools
export PATH=$PATH:$NODE_PATH/bin
 
# Install JDK and Apache Ant
echo "now sudo apt-get -qq -y install default-jdk ant git:"
sudo apt-get -qq -y install default-jdk ant git
 
# Set JAVA_HOME based on the default OpenJDK installed
export JAVA_HOME="$(find /usr -type l -name 'default-java')"
if [ "$JAVA_HOME" != "" ]; then
    echo "export JAVA_HOME=$JAVA_HOME" >> ".profile"
fi

sudo ln -s /opt/node/bin/node /usr/bin/node
sudo ln -s /opt/android-sdk/tools/android /usr/bin/android
 
# Install Apache Cordova and Ionic Framework
npm install -g cordova ionic

cd "$INSTALL_PATH" && sudo chown $USER:$USER -R "node"
cd "$INSTALL_PATH" && sudo chmod -R 754 "node"
 
# Clean up any files that were downloaded from the internet
#cd $WGET_DEST && rm "android-sdk.tgz"
#cd $WGET_DEST && rm "nodejs.tgz"
 
echo "----------------------------------"
echo "Restart your Ubuntu session for installation to complete..."
