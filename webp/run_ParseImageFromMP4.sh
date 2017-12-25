#!/bin/bash
#********************************************************************************
# get picture from mp4
#
#********************************************************************************

runUsage()
{
    echo -e "\033[31m *********************************** \033[0m"
    echo "   Usage:                                     "
    echo "      $0  \$InputMP4                             "
    echo -e "\033[31m *********************************** \033[0m"
}

runPareseDurationAndResolution()
{
    #*************************************************************************
    # get video duration and calculate 1/8 timestamp
    # Duration: 00:00:13.95, start: 0.000000, bitrate: 2644 kb/s
    #
    #another way is using ffprobe In.mp4 to get mpe duration info
    #*************************************************************************
ffmpeg -i ${MP4File} -c copy -y ${MP4File}_copy.mp4 2>${TranscodeLog}
    rm -f ${MP4File}_copy.mp4


    #Duration
    DurationInfo=`cat ${TranscodeLog} | grep "Duration" | awk '{print $2}'`
    Minutes=`echo $DurationInfo | awk 'BEGIN {FS=":"} {print $2}' `
    Seconds=`echo $DurationInfo | awk 'BEGIN {FS=":"} {print $3}'|awk 'BEGIN {FS=","} {print $1}' `
    DurationInSeconds=`echo  "scale=2; 60 * ${Minutes} + $Seconds "   | bc`
    let "DivNum = ${PicNum} + 1"
    FrameInterval=`echo  "scale=2; ${DurationInSeconds} /${DivNum} " | bc`

    #Resolution
    # Stream #0:0(eng): Video: h264 (High) ([33][0][0][0] / 0x0021), yuv420p, 540x960
    # yuv420p(tv, bt709/bt709/bt2020-10), 368x640, 2576 kb/s
    # yuv420p, 540x960 [SAR 1:1 DAR 9:16], 2523 kb/s,
    ResolutionInfo=`cat ${TranscodeLog} | grep "Video: h264" | head -n 1`
    ResolutionInfo=`echo ${ResolutionInfo} | awk 'BEGIN {FS="yuv420p"} {print $NF}'| awk 'BEGIN {FS="kb/s"} {print $1}'`
    ResolutionInfo=`echo ${ResolutionInfo} | awk 'BEGIN {FS=")"} {print $NF}'| awk 'BEGIN {FS=","} {print $2}'|awk '{print $1}'`

    PicW=`echo $ResolutionInfo | awk 'BEGIN {FS="x"} {print $1}'`
    PicH=`echo $ResolutionInfo | awk 'BEGIN {FS="x"} {print $2}'`

    let "OutPicW= $PicW /16 /2 *16"
    [ $? -ne 0 ] && echo "error for calculating OutPicW" && exit 1
    let "OutPicH= $PicH /16 /2 *16"
    [ $? -ne 0 ] && echo "error for calculating OutPicH" && exit 1

    echo -e "\033[32m ****************************************** \033[0m"
    echo -e "\033[32m DurationInfo      is: ${DurationInfo}      \033[0m"
    echo -e "\033[32m DurationInSeconds is: ${DurationInSeconds} \033[0m"
    echo -e "\033[32m FrameInterval     is: ${FrameInterval}     \033[0m"
    echo -e "\033[32m *****************************************  \033[0m"
    echo -e "\033[32m Input  resolution is: ${PicW}x${PicH}      \033[0m"
    echo -e "\033[32m Output resolution is: ${OutPicW}x${OutPicH}\033[0m"
    echo -e "\033[32m ****************************************** \033[0m"
}


runInit()
{
    let "PicNum        = 8"
    let "OutPicW       = 240"
    let "OutPicH       = 360"
    let "FrameInterval = 1"
    Format="image2"
    TranscodeLog="FFMPEGCopyLog.txt"
    FFMPEGPicCMD=""

    runPareseDurationAndResolution
    JPEGQP="0"
}

runParseImageFromMP4()
{
    for((i=1; i<=${PicNum}; i++))
    do
        #get frame timestamp
        TimeStamp=`echo  "scale=2; ${FrameInterval} * $i " | bc`
        IntNum=`echo ${TimeStamp} | awk 'BEGIN {FS="."} {print $1}'`
        [ "${IntNum}" = "" ] && TimeStamp="0${TimeStamp}"

        #output file
        OutputImage="${MP4File}_idx_${i}_q_${JPEGQP}.jpg"
        FFMPEGPicCMD="ffmpeg -ss ${TimeStamp} -i ${MP4File} -an  -s ${OutPicW}x${OutPicH} -qscale ${JPEGQP} -vframes 1 -f ${Format} -y ${OutputImage}"

        #run ffmpeg extract command
        LogFile="FFMPEGLog_Image_$i.txt"
        ${FFMPEGPicCMD} 2>>${LogFile}
        [ $? -ne 0 ] && echo "failed to extract ${i}th jpge file!" && exit 1
    done
}

runCheck()
{
    let "Flag = 1"
    [ ! -e ${MP4File} ] && let "Flag = 0"
    if [ ${Flag} -eq 0 ]
    then
        echo "Input is not a file or dir, please double check"
        runUsage
        exit 1
    fi
}

runMain()
{
    runCheck

    runInit
    runParseImageFromMP4
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
