#!/bin/bash
#********************************************************************************
# extract image from mp4 file
#
#********************************************************************************

runUsage()
{
    echo -e "\033[31m ***************************************** \033[0m"
    echo "   Usage:                                                "
    echo "      $0  \$InputMP4                                   "
    echo "                                                       "
    echo "      --InputMP4:   mp4 for preprpcessing              "
    echo "                                                       "
    echo -e "\033[31m ***************************************** \033[0m"
}

runCapturePictureFromMP4()
{

    let "PicNum    = 30"
    let "OutPicW   = 1080"
    let "OutPicH   = 1920"
    Format="image2"

    #MP4Size=`echo  "scale=2; ${MP4Size} /1024 /1024" | bc`

    for((i=0; i< ${PicNum}; i++))
    do
        TimeStamp=`echo  "scale=2; 0.1 * $i " | bc`
        IntNum=`echo ${TimeStamp} | awk 'BEGIN {FS="."} {print $1}'`
        [ "${IntNum}" = "" ] && TimeStamp="0${TimeStamp}"
        OutputImage="${MP4File}_index_${i}_TS_${TimeStamp}_${Format}.jpg"

        Command="ffmpeg -i ${MP4File} -an -ss ${TimeStamp} -s ${OutPicW}x${OutPicH} -vframes 1 -f ${Format} -y ${OutputImage}"

        echo "Command is ${Command}"
        #run command
        ${Command}

        #webp transcode:
        cwebp ${OutputImage} -q 80 -o ${OutputImage}.webp
    done

#ffmpeg -i ${MP4File} -an -ss ${TimeStamp} -s ${OutPicW}x${OutPicH} -vframes 1 -f ${Format} -y ${OutputImage}

#ffmpeg -i 16x9_480p_sd.mp4 -ss 1.133 -an -vframes 1 -f image2 -y 1.133.jpg
}

runPareseTimeStampInfo()
{
    # get video duration and calculate 1/8 timestamp
    # Duration: 00:00:13.95, start: 0.000000, bitrate: 2644 kb/s
    #*************************************************************************
    ffmpeg -i ${MP4File} -c copy -y ${MP4File}_copy.mp4 2>${TranscodeLog}
    rm -f ${MP4File}_copy.mp4

    DurationInfo=`cat ${TranscodeLog} | grep "Duration" | awk '{print $2}'`
    Minutes=`echo $DurationInfo | awk 'BEGIN {FS=":"} {print $2}' `
    Seconds=`echo $DurationInfo | awk 'BEGIN {FS=":"} {print $3}'|awk 'BEGIN {FS=","} {print $1}' `
    DurationInSeconds=`echo  "scale=2; 60 * ${Minutes} + $Seconds " | bc`
    FrameInterval=`echo  "scale=2; ${DurationInSeconds} / 8 " | bc`

    echo -e "\033[32m ***************************************** \033[0m"
    echo -e "\033[32m DurationInfo      is: ${DurationInfo}     \033[0m"
    echo -e "\033[32m DurationInSeconds is: ${DurationInSeconds}\033[0m"
    echo -e "\033[32m FrameInterval is: ${FrameInterval}        \033[0m"
    echo -e "\033[32m ***************************************** \033[0m"
}

runOutputWebpLog()
{
    echo -e "\033[32m ***************************************** \033[0m"
    echo -e "\033[32m TimeStamp    is: ${TimeStamp}             \033[0m"
    echo -e "\033[32m frame index  is: ${FFMPEGPicCMD}          \033[0m"
    echo -e "\033[32m FFMPEGPicCMD is: ${FFMPEGPicCMD}          \033[0m"
    echo -e "\033[32m WebPCommand  is: ${WebPCommand}           \033[0m"
    echo -e "\033[32m AnimationParam01 is: ${AnimationParam01}  \033[0m"
    echo -e "\033[32m AnimationParam02 is: ${AnimationParam02}  \033[0m"
    echo -e "\033[32m ***************************************** \033[0m"
}

runGenerateAnimationWebP()
{
    let "PicNum        = 8"
    let "OutPicW       = 1080"
    let "OutPicH       = 1920"
    let "FrameInterval = 1"
    Format="image2"
    TranscodeLog="FFMPEGCopyLog.txt"
    LogFile="WebPTranscode.txt"
    FFMPEGPicCMD=""
    WebPCommand=""
    WebPAnimationCMD=""
    WebPOutFile=""
    AnimationParam01=""
    AnimationParam02=""
    AnimationWebp="${MP4File}.webp"
    CleanCMD="rm -f ${LogFile} ${TranscodeLog}"
    #Extract 8 pictures from mp4 file and transcode to webp format
    #*************************************************************************
    echo -e "\033[32m ***************************************** \033[0m"
    echo -e "\033[32m  Preparing for animation webP transcoding \033[0m"
    echo -e "\033[32m  Please wait!                             \033[0m"
    echo -e "\033[32m ***************************************** \033[0m"

    for((i=1; i<=${PicNum}; i++))
    do
        TimeStamp=`echo  "scale=2; ${FrameInterval} * $i " | bc`
        IntNum=`echo ${TimeStamp} | awk 'BEGIN {FS="."} {print $1}'`
        [ "${IntNum}" = "" ] && TimeStamp="0${TimeStamp}"
        OutputImage="${MP4File}_idx_${i}.jpg"
        OutputWebP="${MP4File}_idx_${i}.webp"
        #FFMPEGPicCMD="ffmpeg -i ${MP4File} -an -ss ${TimeStamp} -s ${OutPicW}x${OutPicH} -vframes 1 -f ${Format} -y ${OutputImage}"
        FFMPEGPicCMD="ffmpeg -i ${MP4File} -an -ss ${TimeStamp} -vframes 1 -f ${Format} -y ${OutputImage}"
        WebPCommand="cwebp ${OutputImage} -q 100  -lossless -o ${OutputWebP}"
        CleanCMD="${CleanCMD} ${OutputImage} ${OutputWebP}"

        if [ $i -eq 0 ]; then
            AnimationParam02="-frame ${OutputWebP} +200+b"
            AnimationParam01="-frame ${OutputWebP} +200"
        else
            AnimationParam02="-frame ${OutputWebP} +200 ${AnimationParam02}"
            AnimationParam01="${AnimationParam01} -frame ${OutputWebP} +200"
        fi

        #runOutputWebpLog
        #run ffmpeg extract command
        ${FFMPEGPicCMD} 2>>${LogFile}
        #run webp transcode command
        ${WebPCommand}  2>>${LogFile}
    done

    #generate animation webp
    #*************************************************************************
    WebPAnimationCMD="webpmux ${AnimationParam01} ${AnimationParam02}"
    WebPAnimationCMD="${WebPAnimationCMD} -loop 1000 -bgcolor 255,255,255,255 -o ${AnimationWebp}"
    echo -e "\033[32m ***************************************** \033[0m"
    echo -e "\033[32m WebPAnimationCMD  is: ${WebPAnimationCMD} \033[0m"
    echo -e "\033[32m AnimationWebp     is: ${AnimationWebp}    \033[0m"
    echo -e "\033[32m CleanCMD          is: ${CleanCMD}         \033[0m"
    echo -e "\033[32m ***************************************** \033[0m"
    #*************************************************************************
    # example:
    #*************************************************************************
    # webpmux  -frame ./Test.mp4_idx_1.webp +200 -frame ./Test.mp4_idx_2.webp +200  \
    #          -frame ./Test.mp4_idx_3.webp +200 -frame ./Test.mp4_idx_4.webp +200  \
    #          -frame ./Test.mp4_idx_5.webp +200 -frame ./Test.mp4_idx_6.webp +200  \
    #          -frame ./Test.mp4_idx_7.webp +200 -frame ./Test.mp4_idx_8.webp +200  \
    #          -frame ./Test.mp4_idx_8.webp +200 -frame ./Test.mp4_idx_7.webp +200  \
    #          -frame ./Test.mp4_idx_6.webp +200 -frame ./Test.mp4_idx_5.webp +200  \
    #          -frame ./Test.mp4_idx_4.webp +200 -frame ./Test.mp4_idx_3.webp +200  \
    #          -frame ./Test.mp4_idx_2.webp +200 -frame ./Test.mp4_idx_1.webp +200+b\
    #          -loop 1000 -bgcolor 255,255,255,255 -o ./Test.mp4.webp
    #*************************************************************************

    #run animation webp command
    ${WebPAnimationCMD}
    #clean temp files
    ${CleanCMD}
}

runCheck()
{
    let "Flag = 1"
    [ -f ${MP4File} ] || let "Flag = 0"

    if [ ${Flag} -eq 0 ]
    then
        echo "Mp4File doest not exist, please double check"
        runUsage
        exit 1
    fi
}

runMain()
{
  runCheck

#runCapturePictureFromMP4
runGenerateAnimationWebP
}

#*****************************************************

if [ $# -lt 1 ]
then
    runUsage
    exit 1
fi

MP4File=$1

runMain
#*****************************************************
