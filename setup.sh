#!/bin/bash

sudo add-apt-repository ppa:haxe/releases -y
sudo apt-get update
sudo apt-get install haxe -y
mkdir ~/haxelib && haxelib setup ~/haxelib
haxelib install lime
haxelib install openfl
haxelib install flixel
haxelib run lime setup flixel
haxelib run lime setup -y
haxelib install flixel-tools
haxelib install extension-share

# Be organised
mkdir tools
cd tools

# Install the right hxcpp from gitlab
wget https://github.com/HaxeFoundation/hxcpp/releases/download/v4.3.106/hxcpp-4.3.106.zip
haxelib install ./hxcpp-4.3.106.zip

# Get Android Commandline tools
mkdir android_sdk
wget https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip
unzip commandlinetools-linux-13114758_latest.zip
cd cmdline-tools/
mkdir latest
mv * ./latest/

# Install the right versions (??)
latest/bin/sdkmanager "platform-tools" "platforms;android-36" "build-tools;36.0.0"

# back to tools
cd ..
wget https://dl.google.com/android/repository/android-ndk-r28c-linux.zip
unzip ./android-ndk-r28c-linux.zip

# JDK
wget https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.9%2B10/OpenJDK21U-jdk_x64_linux_hotspot_21.0.9_10.tar.gz
tar -xzf OpenJDK21U-jdk_x64_linux_hotspot_21.0.9_10.tar.gz

haxelib run lime config ANDROID_SDK `pwd`/android_sdk
haxelib run lime config ANDROID_NDK_ROOT `pwd`/android-ndk-r28c
haxelib run lime config JAVA_HOME `pwd`/jdk-21.0.9+10
haxelib run lime config ANDROID_SETUP true