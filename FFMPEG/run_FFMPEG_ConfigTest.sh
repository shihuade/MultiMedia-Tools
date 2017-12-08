#!/bin/bash


runInit()
{
    RootDir=`pwd`
    LibList="libavcodec libavfilter libavformat libavutil libswscale libswresample libavresample libpostproc libavdevice libavresample"
    aLibList=(${LibList})

    OutputDir="${RootDir}/LibFFMPEG_${OutputLabel}"
    if [ -d ${OutputDir} ]; then
        rm -rf ${OutputDir}
    fi
    mkdir -p ${OutputDir}
}

runInitCfgMini()
{
    export COMMON_FF_CFG_FLAGS=
    source ${RootDir}/run_FFMPEG_Cfg_common.sh

    FFMPEG_CFG_FLAGS=
    FFMPEG_CFG_FLAGS="$FFMPEG_CFG_FLAGS $COMMON_FF_CFG_FLAGS"

    # Advanced options (experts only):
    #FFMPEG_CFG_FLAGS="$FFMPEG_CFG_FLAGS --enable-cross-compile"

    # Developer options (useful when working on FFmpeg itself):
    FFMPEG_CFG_FLAGS="$FFMPEG_CFG_FLAGS --disable-stripping"

    FFMPEG_CFG_FLAGS="$FFMPEG_CFG_FLAGS --enable-optimizations"
    FFMPEG_CFG_FLAGS="$FFMPEG_CFG_FLAGS --enable-small"

    FFMPEG_CFG_FLAGS="$FFMPEG_CFG_FLAGS --enable-small --enable-nonfree --enable-gpl --enable-encoder=libx264 --enable-libx264"

    AllCfg="${FFMPEG_CFG_FLAGS}"

    echo -e "\033[32m ************************************************************ \033[0m"
    echo -e "\033[32m  AllCfg is ${AllCfg}                                         \033[0m"
    echo -e "\033[32m ************************************************************ \033[0m"
}

runInitCfg()
{
    CFGBase="--cc=/usr/bin/clang --prefix=/opt/ffmpeg --extra-version=tessus --enable-gpl --enable-nonfree"
    #CFGComDisable01="--disable-avdevice --disable-swresample --disable-swscale --disable-postproc --disable-avfilter"
    #ffmpeg_deps="avcodec avfilter avformat swresample"
    #avresample avutil
    CFGComDisable01="--disable-avdevice  --disable-swscale --disable-postproc"
    #CFGComDisable02="--disable-network --disable-dwt --disable-lsp --disable-lzo --disable-mdct --disable-rdft --disable-fft --disable-faan --disable-pixelutils"
    CFGComDisable02="--disable-network --disable-lsp --disable-lzo  --disable-faan --disable-pixelutils"
    CFGComDisable03="--disable-ffplay --disable-ffprobe  --disable-ffserver --disable-indev=qtkit"
    CFGEnable="--enable-libx264   --enable-libfdk-aac --enable-encoder=aac"

    AllCfg="${CFGBase} ${CFGComDisable01} ${CFGComDisable02} ${CFGComDisable03} ${CFGEnable}"

    echo -e "\033[32m ************************************************************ \033[0m"
    echo -e "\033[32m  AllCfg is ${AllCfg}                                         \033[0m"
    echo -e "\033[32m ************************************************************ \033[0m"
}

runBuildWithCfg()
{
    cd ${FFMPEGSurce}
    git clean -fdx

    echo -e "\033[32m ************************************************************ \033[0m"
    echo -e "\033[32m  configuring for ${AllCfg}                                   \033[0m"
    echo -e "\033[32m ************************************************************ \033[0m"

    ./configure ${AllCfg}

    echo -e "\033[32m ************************************************************ \033[0m"
    echo -e "\033[32m compiling ffmpeg                                             \033[0m"
    echo -e "\033[32m ************************************************************ \033[0m"

    make

    cd ${RootDir}
}

runCopyAllLib()
{
    for lib in ${aLibList[@]}
    do

        LibFile="${FFMPEGSurce}/${lib}/${lib}.a"
        if [ -e ${LibFile} ]; then
            echo -e "\033[32m ************************************************************ \033[0m"
            echo "    copying lib file ${LibFile} to ${OutputDir}"
            echo -e "\033[32m ************************************************************ \033[0m"
            cp -f ${LibFile} ${OutputDir}
        fi
    done

    FFMPEGBin="${FFMPEGSurce}/ffmpeg"
    FFMPEGCfg="${FFMPEGSurce}/config.h"

    [ -e ${FFMPEGBin} ] && cp -f ${FFMPEGBin}  ${OutputDir}
    [ -e ${FFMPEGCfg} ] && cp -f ${FFMPEGCfg}  ${OutputDir}
}

runMain()
{
    runInit

runInitCfgMini
#runInitCfg

    runBuildWithCfg

    runCopyAllLib
}

#***************************************************************
FFMPEGSurce=$1
OutputLabel=$2

if [ "${FFMPEGSurce}X" = "X" ]; then
    FFMPEGSurce="/Users/edward.shi/project/video/FFMPEG/ffmpeg"
fi


if [ "${OutputLabel}X" = "X" ]; then
    OutputLabel="Non"
fi

runMain
#***************************************************************



