#!/bin/bash

#***********************************************************
# brief:
#     openh264 build for ios
#
# env requirement:
#     nasm version 2.11 above
#
#***********************************************************

function InitVar {
    CWD=`pwd`
    SOURCE="openh264"
    CODEC_LIB="libopenh264.a"

    SimArch="i386 x86_64"
    DeviceArch="armv7 armv7s arm64"

    Openh264Repos="https://github.com/cisco/openh264.git"
    GASRepos="https://github.com/libav/gas-preprocessor.git"
    GAS_PREPROCESSOR=/usr/local/bin/gas-preprocessor.pl

    ThinLibDir="${CWD}/thin-openh264"
    FatLibDir="${CWD}/openh264-iOS"
}

function CheckGasScript {
    if [ ! -r $GAS_PREPROCESSOR ];then
        echo -e "\033[32m gas-preprocessor.pl not found. Trying to install...\033[0m"
        rm -rf gas-preprocessor
        git clone ${GASRepos}
        cp  gas-preprocessor/gas-preprocessor.pl ${GAS_PREPROCESSOR}
        chmod u+x ${GAS_PREPROCESSOR}
    fi
}

function CheckOpenh264Source {
    if [ ! -r ${SOURCE} ]; then
        echo -e "\033[32m openh264 source not found. Trying to download...\033[0m"
        git clone ${Openh264Repos}
    fi
}

function BuildOpenh264 {
    cd ${SOURCE}
    for arch in ${TargetArch[@]}
    do
        TargetDir="${ThinLibDir}/${arch}"
        [ -d "${TargetDir}" ] && rm -rf ${TargetDir}
        mkdir -p ${TargetDir}

        echo -e "\033[32m ********************************** \033[0m"
        echo -e "\033[32m building arch is ${arch}           \033[0m"
        echo -e "\033[32m please wait...                     \033[0m"
        echo -e "\033[32m ********************************** \033[0m"
        make OS=ios ARCH=${arch} clean >iOS_Build.log
        make OS=ios ARCH=${arch} BUILDTYPE=Release HAVE_GTEST=No PREFIX="${TargetDir}" install-static
        if [ $? -ne 0 ]; then
            echo -e "\033[31m Build failed for ios with ARCH=${arch} \033[0m"
            cd ${CWD}
            exit 1
        fi
    done
    cd ${CWD}
}

function LipoFatLib() {
    LipoCommand=""
    for arch in ${TargetArch[@]}
    do
        TargetDir="${ThinLibDir}/${arch}"
        if [ -e ${TargetDir}/${CODEC_LIB} ]; then
                LipoCommand="${LipoCommand} -arch ${arch} ${TargetDir}/${CODEC_LIB}"
        fi
    done

    [ "${LipoCommand}X" = "X" ] && return 0

    TargetFatLibDir="${FatLibDir}/${Platform}"
    mkdir -p ${TargetFatLibDir}
    LipoCommand="lipo -create ${LipoCommand} -output ${TargetFatLibDir}/${CODEC_LIB}"
    ${LipoCommand}

    echo -e "\033[32m ******************************************** \033[0m"
    echo -e "\033[32m LipoCommand is ${LipoCommand}                \033[0m"
    echo -e "\033[32m arch info for final openh264 lib:            \033[0m"
    echo -e "\033[32m ******************************************** \033[0m"
    lipo -info ${TargetFatLibDir}/${CODEC_LIB}
}

function LibpoFatForAll {
    TargetArch="${SimArch}"
    Platform="iPhoneSimulator"
    LipoFatLib

    TargetArch="${DeviceArch}"
    Platform="iPhoneOS"
    LipoFatLib
}

function Main {
    InitVar
    CheckGasScript
    CheckOpenh264Source

    BuildOpenh264

    LibpoFatForAll
}
#************************************************************************************

if [ $# -lt 1 ]
then
    runUsage
    exit 1
fi
TargetArch="$@"
Main
