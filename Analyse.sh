#!/bin/bash
#***************************************************
#for ffmpeg:
# install:
# git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg
# cd FFMPEG
# ./configure $yout option
# make install
#***************************************************

runInit()
{
    #Douyin cache dir
    DouYinCacheDir="/sdcard/Android/data/com.ss.android.ugc.aweme/cache/video/cache"
    DouYinDestDir="DouYinCache"
    DouYinStreamDir="${DouYinDestDir}/cache"

    #Muse cache dir
    MuseCacheDir="/sdcard/Android/data/com.zhiliaoapp.musically/files/videos"
    MuseDestDir="MuseCache"
    MuseStreamDir="${MuseDestDir}/videos"

    #remove previous data
    [ -d ${DouYinDestDir} ] && rm -rf ${DouYinDestDir}
    [ -d ${MuseDestDir} ]   && rm -rf ${MuseDestDir}

    #create new dest dir
    mkdir ${DouYinDestDir}
    mkdir ${MuseDestDir}
}

runPullFromAndroid()
{

    #pull and extract from douyin cache
    Command="adb pull -a ${DouYinCacheDir} ${DouYinDestDir}"
    echo "**********************************************"
    echo "Start to pull from douyin"
    echo "Command is:"
    echo " ${Command}"
    echo "**********************************************"
    ${Command}
    [ ! $? -eq 0 ] && exit 1

    #pull and extract from muse cache
    Command="adb pull -a ${MuseCacheDir} ${MuseDestDir}"
    echo "**********************************************"
    echo "Start to pull from muse"
    echo "Command is:"
    echo " ${Command}"
    echo "**********************************************"
    ${Command}
    [ ! $? -eq 0 ] && exit 1
}

runExtract264FromMP4()
{
    #extract from douyin mp4
    echo "**********************************************"
    echo "Start to extract from douyin"
    echo "**********************************************"
    for file in ${DouYinStreamDir}/*
    do
        echo "**********************************************"
        echo "file is ${file}"
        echo "add .mp4 postfix"
        echo "**********************************************"

        cp ${file} ${file}.mp4
        FFMPEGCMD="ffmpeg -i ${file}  -vbsf h264_mp4toannexb -vcodec copy -f h264 ${file}.264"
        echo "start to extract h264 bit stream from mp4 file"
        echo "FFMPEGCMD is: ${FFMPEGCMD}"
        ${FFMPEGCMD}
    done

    #extract from muse mp4
    echo "**********************************************"
    echo "Start to extract from muse"
    echo "**********************************************"
    for file in ${MuseStreamDir}/*
    do
        echo "**********************************************"
        echo "file is ${file}"
        echo "start to extract h264 bit stream from mp4 file"
        echo "**********************************************"

        FFMPEGCMD="ffmpeg -i ${file}  -vbsf h264_mp4toannexb -vcodec copy -f h264 ${file}.264"
        echo "FFMPEGCMD is: ${FFMPEGCMD}"
        ${FFMPEGCMD}
    done

    echo "*******************************************************"
    echo "all files in douyin and muse have been extracted!"
    echo "*******************************************************"
}


runAnayse(){

  VideoDouYin="ios_android_douyin.mp4"
  VideoMuse="ios_muse_broswer.mp4"

  BitStreamDouYin="${VideoDouYin}.ffmpeg_trans.264"
  BitStreamMuse="${VideoMuse}.ffmpeg_trans.264"

  YUVDouYin="${VideoDouYin}.JM.dec.yuv"
  YUVMuse="${VideoMuse}.JM.dec.yuv"

  git clean -fdx

  ffmpeg -i ${VideoDouYin} -vbsf h264_mp4toannexb -vcodec copy -an ${BitStreamDouYin}  >FFMPEGTrans.log   2>&1
  ffmpeg -i ${VideoMuse} -vbsf h264_mp4toannexb -vcodec copy   -an ${BitStreamMuse}    >>FFMPEGTrans.log  2>&1

  ./JMDecoder -p "InputFile=${BitStreamDouYin}" -p "OutputFile=${YUVDouYin}" >JMDecoded.log
  ./JMDecoder -p "InputFile=${BitStreamMuse}"   -p "OutputFile=${YUVMuse}"   >>JMDecoded.log
}

runMain()
{
    runInit
    runPullFromAndroid
    runExtract264FromMP4
}

runMain


