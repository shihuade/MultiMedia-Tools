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
    echo  -e "\033[32m  AllCfg is ${AllCfg}"
    echo -e "\033[32m ************************************************************ \033[0m"
}

runBuildWithCfg()
{
    cd ${FFMPEGSurce}
    git clean -fdx

    echo -e "\033[32m ************************************************************ \033[0m"
    echo  -e "\033[32m  configuring for ${AllCfg}"
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
    runInitCfg

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



