#!/bin/bash
#***************************************************************
# brief:
#       get ffmpeg x264 lib's path
#***************************************************************

runUsage()
{
    echo -e "\033[31m *****************************************\033[0m"
    echo "     Usage:                                                 "
    echo "          $0  \$FFMPEGDir \${x264Dir} \$Option              "
    echo "                                                            "
    echo -e "\033[31m *****************************************\033[0m"
}

runInit()
{
    ConfigShell="${FFMPEGDir}/ffbuild/config.sh"
    x264NoSEIBuildScript="run_DisableSEIInfo.sh"
    x264LibPathScript="run_ParseFFMPEGx264LibPath.sh"

    FFMPEGx264LibPath=""

    x264Bin="x264"
    x264Lib="libx264.a"
    ax264HeadFileList=("x264.h" "x264_config.h")

    #check OS
    #*************
    OSType=`uname`
    if [[ "$OSType" =~ "Darwin" ]]; then
        OSType="Mac"
        x264DefaultLiptPath="/usr/local/Cellar/x264/r2748/lib"
        x264Dylib="libx264.dylib"
        x264Suffix="*.dylib"
    else
        OSType="Linux"
        x264DefaultLiptPath="/usr/local/Cellar/x264/r2748/lib"
        x264Dylib="libx264.so"
        x264Suffix="*.so"
    fi

    #FFMPEG setting
    #*******************
    FFMPEGConfigShell="${FFMPEGDir}/ffbuild/config.sh"
    FFMPEGBuildPreset="--enable-gpl --enable-libx264"
    #configuration: --cc=/usr/bin/clang --prefix=/opt/ffmpeg --extra-version=tessus --enable-avisynth --enable-fontconfig --enable-gpl --enable-libass --enable-libbluray --enable-libfreetype --enable-libgsm --enable-libmodplug --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libopus --enable-libsnappy --enable-libsoxr --enable-libspeex --enable-libtheora --enable-libvidstab --enable-libvo-amrwbenc --enable-libvorbis --enable-libvpx --enable-libwavpack --enable-libx264 --enable-libx265 --enable-libxavs --enable-libxvid --enable-libzmq --enable-libzvbi --enable-version3 --disable-ffplay --disable-indev=qtkit


    #x264 build option
    x264BuildOption=`echo "${Params}" | grep "SEI"`
    if [ -n "${x264BuildOption}" ]; then
        x264BuildOption="SEI"
    else
        x264BuildOption="NoSEI"
    fi

    #ffmpeg build option
    FFMPEGBuildOption=`echo "${Params}" | grep "SkipBuild"`
    if [ -n "${FFMPEGBuildOption}" ]; then
        FFMPEGBuildOption="SkipBuild"
    else
        FFMPEGBuildOption="Build"
    fi
}

runGetFFMPEGx264LibPath()
{
    if [ ! -e "${FFMPEGConfigShell}" ];then
        echo -e "\033[31m ***************************** \033[0m"
        echo -e "\033[31m   FFMPEGConfigShell not found \033[0m"
        echo -e "\033[31m   need to configure for build \033[0m"
        echo -e "\033[31m ***************************** \033[0m"

        runConfigFFMPEG
    fi

    FFMPEGx264LibPath=`./${x264LibPathScript} ${FFMPEGDir}`
    FFMPEGx264LibPath=`echo $FFMPEGx264LibPath | awk '{print $NF}'`

    [ -z "$FFMPEGx264LibPath" ] && echo "can not find ffmpeg x264 lib path!" && exit 1
    echo "FFMPEGx264LibPath is $FFMPEGx264LibPath"
}

runGenerateSHA1ForLib()
{
    SystemDylibSHA1=`openssl sha1 ${FFMPEGx264LibPath}/${x264Dylib} | awk 'BEGIN {FS="="} {print $NF}'`
    SystemLibSHA1=`openssl   sha1 ${FFMPEGx264LibPath}/${x264Lib}   | awk 'BEGIN {FS="="} {print $NF}'`

    x264Dylib=`find ${x264Dir} -name "libx264*${x264Suffix}"`
    x264DylibSHA1=`openssl sha1 ${x264Dylib} | awk 'BEGIN {FS="="} {print $NF}'`
    x264LibSHA1=`openssl   sha1 ${x264Dir}/${x264Lib}   | awk 'BEGIN {FS="="} {print $NF}'`
}

runCheckx264Lib()
{
    let "Flag = 0"
    if [ "$SystemDylibSHA1" != "$x264DylibSHA1"  ]; then
        echo  -e "\033[31m $x264Dylib between x264 and system are not the same one, need to update \033[0m"
        echo "    $SystemDylibSHA1--$x264DylibSHA1"
        let "Flag = 1"
    fi

    if [ "$SystemLibSHA1" != "$x264LibSHA1"  ]; then
        echo  -e "\033[31m $x264Lib between x264 and system are not the same one, need to update \033[0m"
        echo "    $SystemLibSHA1--$x264LibSHA1"
        let "Flag = 1"
    fi

    #check x264 head files
    SystemIncludePath=`echo "$FFMPEGx264LibPath" | awk 'BEGIN {FS="lib"} {print $1}'`
    SystemIncludePath="${SystemIncludePath}include"
    for file in ${ax264HeadFileList[@]}; do

        SystemHeadSHA1=`openssl sha1 ${SystemIncludePath}/${file} | awk 'BEGIN {FS="="} {print $NF}'`
        x264HeadSHA1=`openssl sha1 ${x264Dir}/${file} | awk 'BEGIN {FS="="} {print $NF}'`

        if [ "$SystemHeadSHA1" != "$x264HeadSHA1"  ];then
            echo  -e "\033[31m $file between x264 and system are not the same, need to update \033[0m"
            echo "    $SystemHeadSHA1--$x264HeadSHA1"
            let "Flag = 1"
        fi
    done

    if [ $Flag -eq 1 ];then
        echo -e "\033[31m ***************************************************************\033[0m"
        echo -e "\033[31m    x264 lib or dylib or head file are not the same with system \033[0m"
        echo -e "\033[31m    please update your system's x264 lib/dylib/head file        \033[0m"
        echo -e "\033[31m    ax264HeadFileList:  ${ax264HeadFileList[@]}                 \033[0m"
        echo -e "\033[31m    x264Dylib:          ${x264Dylib}                            \033[0m"
        echo -e "\033[31m    x264Lib:            ${x264Lib}                              \033[0m"
        echo -e "\033[31m    SystemIncludePath:  ${SystemIncludePath}                    \033[0m"
        echo -e "\033[31m    FFMPEGx264LibPath:  ${FFMPEGx264LibPath}                    \033[0m"
        echo -e "\033[31m ***************************************************************\033[0m"
        exit 1
    fi
}

runBuildx264Special()
{
    ./${x264NoSEIBuildScript} ${x264Dir} "${x264BuildOption}"
    if [ $? -ne 0 ]; then
        echo -e "\033[31m *********************\033[0m"
        echo " x264 build failed!                     "
        echo -e "\033[31m *********************\033[0m"
        exit 1
    fi
}

runConfigFFMPEG()
{
    cd ${FFMPEGDir}

    echo -e "\033[33m *****************************************\033[0m"
    echo -e "\033[33m FFMPEGBuildPreset is $FFMPEGBuildPreset  \033[0m"
    echo -e "\033[33m   configuring ffmpeg build               \033[0m"
    echo -e "\033[33m   please wait                            \033[0m"
    echo -e "\033[33m *****************************************\033[0m"

    ./configure ${FFMPEGBuildPreset}
    [ $? -ne 0 ] && echo "ffmpeg build configure failed!" && cd - && exit 1

    cd -
}

runBuildFFMPEG()
{
    cd ${FFMPEGDir}

    echo -e "\033[33m ***************************\033[0m"
    echo -e "\033[33m   start to build ffmpeg    \033[0m"
    echo -e "\033[33m ***************************\033[0m"

    make clean
    make

    cd -
}

runPrompt()
{
    echo -e "\033[32m ***************************************************************\033[0m"
    echo -e "\033[33m   ffmpeg build with special x264 success! \033[0m"
    echo -e "\033[32m ***************************************************************\033[0m"
    echo -e "\033[33m    FFMPEGBuildOption:  ${FFMPEGBuildOption}                    \033[0m"
    echo -e "\033[33m    x264BuildOption:    ${x264BuildOption}                      \033[0m"
    echo -e "\033[32m ***************************************************************\033[0m"
    echo -e "\033[33m    ax264HeadFileList:  ${ax264HeadFileList[@]}                 \033[0m"
    echo -e "\033[33m    x264Dylib:          ${x264Dylib}                            \033[0m"
    echo -e "\033[33m    x264Lib:            ${x264Lib}                              \033[0m"
    echo -e "\033[33m    SystemIncludePath:  ${SystemIncludePath}                    \033[0m"
    echo -e "\033[33m    FFMPEGx264LibPath:  ${FFMPEGx264LibPath}                    \033[0m"
    echo -e "\033[32m ***************************************************************\033[0m"
}

runCheck()
{
    [ -d ${FFMPEGDir} ] || [  -d ${x264Dir} ] || Flag="Failed"
    if [ "$Flag" = "Failed" ];then
        echo "FFMPE/x264 dir doest not exist, please double check"
        runUsage
        exit 1
    fi
}



runMain()
{
    runInit

    runCheck

    if [ "$FFMPEGBuildOption" = "Build" ];then
        runConfigFFMPEG
        runGetFFMPEGx264LibPath

        runBuildx264Special
        runGenerateSHA1ForLib
        runCheckx264Lib

        runBuildFFMPEG
    else
        runGetFFMPEGx264LibPath
        #runBuildx264Special
        runGenerateSHA1ForLib
        runCheckx264Lib
    fi

    runPrompt
}

#*************************************************************
[ $# -lt 2 ] && runUsage && exit 1
[ -n "$NeedHelp" ] && echo "\$@ is ---$@-" && runUsage && exit 0

Params=$@
FFMPEGDir=$1
x264Dir=$2
Option=$3


runMain

#*************************************************************





