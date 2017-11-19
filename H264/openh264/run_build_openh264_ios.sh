#!/bin/bash

#***********************************************************
# brief:
#     openh264 build for ios
#
# env requirement:
#     nasm version 2.11 above
#
#***********************************************************

DISTRIBUTION_PATH=../../distribution/ios
CODEC_PROJECT_PATH=../../vendor/openh264
CODEC_LIB="libopenh264.a"

SimArch="i386 x86_64"
DeviceArch="armv7 armv7s arm64"

Arch="dev"
Config="Release"
Clean="false"
BuildDownload="build"
TargetArch=""

#for last build history
LastBuildFlag="False"
BuildCfgFlag="False"
LastBuildCfg=""
LibVersionInfo=""
BinDir=""
BinFile=""


function ShowUsage {
    echo "******************************************"
    echo "  usage for building/download openh264 for ios     "
    echo "      $0 [dev/sim] [debug/release] [clean] [openh264-skip-build] "
	echo " "
	echo "         dev: optional, build openh264 for devices. default is dev"
	echo "         sim: optional, build openh264 for simulator "
	echo "         debug: optional, build Debug mode "
	echo "         release: optional, build Release mode, default is Release "
	echo "         clean: optional, clean old lib before build"
	echo "         openh264-skip-build: optional, skip build openh264, but dowload form ftp "
    echo "  "
    echo "  example:"
    echo "    build openh264 lib for devices on release,and clean before build: "
	echo "        $0 dev release clean "
	echo "     or $0 clean "
	echo " "
    echo "  example:"
    echo "    skip build and dowload openh264.lib form ftp:"
	echo "        $0 dev release clean openh264-skip-build "
	echo "     or $0 openh264-skip-build"
    echo "******************************************"
}


#parse parameters
while [ $# -gt 0 ]; do
case $1 in
    dev)
	    Arch="dev"
		shift
	    ;;
    sim)
	    Arch="sim"
		shift
	    ;;
    debug)
	    Config="Debug"
		shift
	    ;;
    release)
	    Config="Release"
		shift
	    ;;
    clean)
	    Clean="true"
		shift
	    ;;
    openh264-skip-build)
	    BuildDownload="skip-build"
		shift
	    ;;
    *)
	    echo "Error: invalid parameter: $1"
		ShowUsage
		shift
		exit 1
	    ;;
esac
done


function OutputParam {

    echo "******************************************"
    echo "OpenH264 Info: "
    echo "Arch   is:  ${TargetArch}"
    echo "Config is:  ${Config}"
    echo "Clean  is:  ${Clean}"
    echo "BuildDownload is:  ${BuildDownload}"
    echo "******************************************"
}


function InitVar {

    LipoCommand="lipo -create"

    if [ "${Arch}" = "sim" ]; then
        TargetDir="${Config}-iphonesimulator" && DebugTargetDir="Debug-iphonesimulator"
        TargetArch="${SimArch}"
    elif [ "${Arch}" = "dev" ]; then
        TargetDir="${Config}-iphoneos" && DebugTargetDir="Debug-iphoneos"
        TargetArch="${DeviceArch}"
    fi

    #var for build history
    BinDir="bin/ios/${Arch}/${Config}"
    BinFile="${BinDir}/${CODEC_LIB}"
    LastBuildCfg="ios_${Arch}_${Config}.last_build_cfg"

    LibVersion=`git submodule | grep "openh264" | awk '{print $1}'`
    LibVersionInfo="${BinDir}/${LibVersion}.last_build_commit"

}


function CleanHistory {
    [ -d "${BinDir}" ]     && rm -rf "${BinDir}"
    [ -d "${TargetDir}" ]  && rm -rf "${TargetDir}"
    [ "$BuildDownload" = "build" ]  && [ -e "${LastBuildCfg}" ] && rm -f "${LastBuildCfg}"
}


function CleanOpenH264 {

    cd ${CODEC_PROJECT_PATH}
    make OS=ios clean >iOS_clean.log

    #remove last build history, thus will trigger rebuild logic later
    CleanHistory
    cd -
}


function CheckOpenH264BuildHistory {

    cd ${CODEC_PROJECT_PATH}
    [ -e "${BinFile}" ] && [ -e "${LibVersionInfo}" ] && LastBuildFlag="True"

    #clean build history if no last build or last build version not match current commit ID
    [ "${LastBuildFlag}" = "False" ] && CleanHistory

    #copy last build lib to codec root dir
    [ "${LastBuildFlag}" = "True" ]  && cp -f ${BinFile}  ${TargetDir}/${CODEC_LIB}

    #if there is build history but last build is not for ios(like mac etc.) version, will set to false
    [ -e "${LastBuildCfg}" ] && BuildCfgFlag="True"
    cd -
}


function BuildOpenh264 {

    #goto openh264 dir and buil for all archs
    echo "start to build openh264 "
    echo "TargetDir is ${TargetDir}"
    cd ${CODEC_PROJECT_PATH}
   #clean build history
    git clean -f  ./*.last_build_cfg

    [ -d "${TargetDir}" ] && rm -rf ${TargetDir}
    mkdir ${TargetDir}

    for arch in ${TargetArch[@]}
    do
        TempTarget="${TargetDir}/libopenh264_${arch}.a"
        make OS=ios ARCH=${arch} clean >iOS_Build.log
        make OS=ios ARCH=${arch} BUILDTYPE=${Config} >>iOS_Build.log
        if [ $? -ne 0 ]; then
            cat iOS_Build.log
            echo "Build failed for ios with ARCH=${arch} BUILDTYPE=${Config}"
            exit 1
        fi
        mv ${CODEC_LIB}  ${TempTarget}
        LipoCommand="${LipoCommand} -arch ${arch} ${TempTarget}"
    done

    #generate one lib for all arch
    LipoCommand="${LipoCommand} -output ${TargetDir}/${CODEC_LIB}"
    echo "LipoCommand is ${LipoCommand} "
    ${LipoCommand}
    echo "arch info for final openh264 lib:"
    lipo -info ${TargetDir}/${CODEC_LIB}
    #rm -f ${TargetDir}/libopenh264_*

    #add last build cfg file
    touch ${LastBuildCfg}
    cd -
}


function DownloadOpenH264(){
    cd ${CODEC_PROJECT_PATH}
    OpenH264Dir=`pwd`

    #clean prevous download history
    git clean -f ./*.tar
    rm -rf ${TargetDir}
    [ -d openh264-jenkins ] && rm -rf openh264-jenkins

    #clone download script
    ScriptCloneCmd="git clone git@sqbu-github.cisco.com:OpenH264/openh264-jenkins.git openh264-jenkins"
    echo "ScriptCloneCmd is ${ScriptCloneCmd}"
    ${ScriptCloneCmd}
    if [ $? -ne 0 ]; then
        echo "Error: clone download script from openh264-jenkins error"
        exit 1
    fi

    #always download the release openh264 library for WME
    bash openh264-jenkins/run_DownloadFromFTPServer.sh "ios" "lib" "${Arch}" "${Config}" "${OpenH264Dir}"
    if [ $? -ne 0 ]; then
        echo "Error: download openh264 ios lib from ftp server failed"
        exit 1
    fi

    tar -xvf libopenh264_${Arch}_${Config}_ios.tar
    rm -rf openh264-jenkins
    cd -
}

function UpdateOpenH264Lib {

    mkdir -p ${DISTRIBUTION_PATH}/${TargetDir}

    CopyCommand="cp -f ${CODEC_PROJECT_PATH}/${TargetDir}/${CODEC_LIB}  $DISTRIBUTION_PATH/${TargetDir}/"
    echo "****************************************************"
    echo "    copy openh264 lib to wme distribution dir"
    echo "    ${CopyCommand}"
    echo "****************************************************"
    ${CopyCommand}

    #always release build for wme
    #copy openh264 release lib to wme debug distribution dir in case wme debug build
    if [ "${Config}" = "Release" ]; then
        mkdir -p ${DISTRIBUTION_PATH}/${DebugTargetDir}
        CopyCommand=" cp -f ${CODEC_PROJECT_PATH}/${TargetDir}/${CODEC_LIB}  ${DISTRIBUTION_PATH}/${DebugTargetDir}"
        echo "    copy debug lib for wme-debug build: ${CopyCommand}"
        ${CopyCommand}
    fi
}


function CreateBuildAndUpdateHistory {

    echo "****************************************************"
    echo "    Add build/update history for next build check"
    echo "    BinFile is:         ${BinFile}"
    echo "    LibVersionInfo is:  ${LibVersionInfo}"
    echo "****************************************************"

    cd ${CODEC_PROJECT_PATH}
    mkdir -p ${BinDir}
    cp -f ${TargetDir}/${CODEC_LIB} ${BinDir}
    touch ${LibVersionInfo}
    cd -
}


function CleanAndReBuild {

    CleanOpenH264

    if [ "$BuildDownload" = "build" ]; then
        BuildOpenh264
    elif [ "${BuildDownload}" = "skip-build" ]; then
        DownloadOpenH264
    fi
}


function BuildBasedOnLastBuild {

    CheckOpenH264BuildHistory

    #for case that there is previous build libs
    if [ "${LastBuildFlag}" = "False" ]; then
        [ "$BuildDownload"   = "build" ]      && CleanOpenH264 && BuildOpenh264
        [ "${BuildDownload}" = "skip-build" ] && DownloadOpenH264
    fi
}

function OutputSummary {
    let "SummaryIdx = 0"
    [ "${Clean}" = "true" ]  && [ "$BuildDownload"  = "build" ]      && let "SummaryIdx= 0"
    [ "${Clean}" = "true" ]  && [ "$BuildDownload"  = "skip-build" ] && let "SummaryIdx= 1"
    [ "${Clean}" = "false" ] && [ "${LastBuildFlag}" = "True" ]  && [ "$BuildDownload" = "build" ]      && let "SummaryIdx= 2"
    [ "${Clean}" = "false" ] && [ "${LastBuildFlag}" = "True" ]  && [ "$BuildDownload" = "skip-build" ] && let "SummaryIdx= 3"
    [ "${Clean}" = "false" ] && [ "${LastBuildFlag}" = "False" ] && [ "$BuildDownload" = "build" ]      && let "SummaryIdx= 4"
    [ "${Clean}" = "false" ] && [ "${LastBuildFlag}" = "False" ] && [ "$BuildDownload" = "skip-build" ] && let "SummaryIdx= 5"

    [ ${SummaryIdx} -eq 0 ] && echo "\033[32m\n Clean: remove previous build history, and rebuild successfully\033[0m"
    [ ${SummaryIdx} -eq 1 ] && echo "\033[32m\n Clean: remove previous build history, and download from ftp server successfully\033[0m"
    [ ${SummaryIdx} -eq 2 ] && echo "\033[32m\n No build, copy preivous build libs to wme successfully\033[0m"
    [ ${SummaryIdx} -eq 3 ] && echo "\033[32m\n No ftp download, copy previous libs to wme successfully\033[0m"
    [ ${SummaryIdx} -eq 4 ] && echo "\033[32m\n No previous build history,rebuild libs for wme successfully\033[0m"
    [ ${SummaryIdx} -eq 5 ] && echo "\033[32m\n No previous build libs, re-download libs for wme successfully\033[0m"

    echo "******build/update lib for wme iOS successfully*****"
}


#Main entry
#****************************************************************************************
#----if clean is true:
#        remove all previous history,
#        clean,rebuild,update lib and create build/update history
#----if clean is false:
#        build based on last build history
#            ----if there is last build lib
#                update lib and create build/update history
#            ----if there is no last build lib
#                clean, build,update lib and create build/update history
#  note:
#      As History check is based on openh264 commit ID,
#      so If you want to build you lastest code, please commit to openh264 repos
#
#****************************************************************************************
function Main {

    InitVar
    OutputParam

    if [ "${Clean}" = "true" ]; then
        CleanAndReBuild
    else
        BuildBasedOnLastBuild
    fi

    #copy openh264 libs to distribution dir
    UpdateOpenH264Lib

    #create build history for last build check
    CreateBuildAndUpdateHistory

    OutputSummary
}
#****************************************************************************************
Main
