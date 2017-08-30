#!/bin/bash
#********************************************************************************
# generate animation webp from mp4 file
#
# solution: ffmpeg + cwebp + webpmux
#             ffmpeg:  extract jpg files for mp4 file
#             cwebp:   transcode jpg file to webp format
#             webpmux: transcode webp files to animation webp
#
# ref:
#     ffmpeg:  http://ffmpeg.org/
#     webp:    https://developers.google.com/speed/webp/
#     cwebp:   https://developers.google.com/speed/webp/docs/cwebp
#     webpmux: https://developers.google.com/speed/webp/docs/webpmux
#     webp libs and bins:
#       https://storage.googleapis.com/downloads.webmproject.org/releases/webp/index.html
#
#********************************************************************************

runUsage()
{
    echo -e "\033[31m *********************************** \033[0m"
    echo "   Usage:                                     "
    echo "      $0  \$Input                             "
    echo "      --InputMP4:    transcode given mp4 file "
    echo "      --InputMP4Dir: transcode all mp4 files  "
    echo -e "\033[31m *********************************** \033[0m"
}

runPareseDurationAndResolution()
{
    # get video duration and calculate 1/8 timestamp
    # Duration: 00:00:13.95, start: 0.000000, bitrate: 2644 kb/s
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

runOutputWebpLog()
{
    echo -e "\033[32m ***************************************** \033[0m"
    echo -e "\033[32m TimeStamp    is: ${TimeStamp}             \033[0m"
    echo -e "\033[32m frame index  is: ${i}                     \033[0m"
    echo -e "\033[32m FFMPEGPicCMD is: ${FFMPEGPicCMD}          \033[0m"
    echo -e "\033[32m WebPCommand  is: ${WebPCommand}           \033[0m"
    echo -e "\033[32m AnimationParam01 is: ${AnimationParam01}  \033[0m"
    echo -e "\033[32m AnimationParam02 is: ${AnimationParam02}  \033[0m"
    echo -e "\033[32m ***************************************** \033[0m"
}

runGenerateAnimationWebP()
{
    let "PicNum        = 8"
    let "OutPicW       = 540"
    let "OutPicH       = 960"
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
    echo -e "\033[32m  MP4File ${MP4File}                       \033[0m"
    echo -e "\033[32m  Preparing for animation webP transcoding \033[0m"
    echo -e "\033[32m  Please wait!                             \033[0m"
    echo -e "\033[32m ***************************************** \033[0m"

    runPareseDurationAndResolution
    SkipFlag="False"
    for((i=1; i<=${PicNum}; i++))
    do
        #get frame timestamp
        TimeStamp=`echo  "scale=2; ${FrameInterval} * $i " | bc`
        IntNum=`echo ${TimeStamp} | awk 'BEGIN {FS="."} {print $1}'`
        [ "${IntNum}" = "" ] && TimeStamp="0${TimeStamp}"

        #output file
        OutputImage="${MP4File}_idx_${i}.jpg"
        OutputWebP="${MP4File}_idx_${i}.webp"

        FFMPEGPicCMD="ffmpeg -i ${MP4File} -an -ss ${TimeStamp} -s ${OutPicW}x${OutPicH} -vframes 1 -f ${Format} -y ${OutputImage}"
        #WebPCommand="cwebp ${OutputImage} -q 100  -lossless -o ${OutputWebP}"
        WebPCommand="cwebp ${OutputImage} -q 100 -o ${OutputWebP}"
        CleanCMD="${CleanCMD} ${OutputImage} ${OutputWebP}"

        #run ffmpeg extract command
        ${FFMPEGPicCMD} 2>>${LogFile}
        [ $? -ne 0 ] && echo "failed to extract ${i}th jpge file!" && exit 1

        #run webp transcode command
        ${WebPCommand}  2>>${LogFile}
        Flag=$?
        [ $Flag -ne 0 ] && [ $i -ne ${PicNum} ] && SkipFlag="True"
        [ "$SkipFlag" = "True" ] && echo "failed to transcode ${i}th webp file!" && exit 1

        #skip last frame due to incorrect timestamp
        if [ $Flag -ne 0 ];then
            AnimationParam02="${AnimationParam02}"
            AnimationParam01="${AnimationParam01}"
            break
        fi

        if [ $i -eq 0 ]; then
            AnimationParam02="-frame ${OutputWebP} +200+b"
            AnimationParam01="-frame ${OutputWebP} +200"
        else
            AnimationParam02="-frame ${OutputWebP} +200 ${AnimationParam02}"
            AnimationParam01="${AnimationParam01} -frame ${OutputWebP} +200"
        fi

        runOutputWebpLog

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
    [ $? -ne 0 ] && echo "failed to transcode animation webp file!" && exit 1
    #clean temp files
    ${CleanCMD}
}

runTranscodeAllMP4Files()
{
    for file in ${InputDir}/*.mp4
    do
        MP4File=$file
        runGenerateAnimationWebP
    done
}

runCheck()
{
    let "Flag = 1"
    [ -e ${Input} ] || [ -d ${Input} ] || let "Flag = 0"
    if [ ${Flag} -eq 0 ]
    then
        echo "Input is not a file or dir, please double check"
        runUsage
        exit 1
    fi

    [ -d ${Input} ] && InputDir="$Input"
    [ -f ${Input} ] && InputDir=`dirname $Input`
}

runMain()
{
    runCheck

    if [ -f ${Input} ]; then
        MP4File=$Input
        runGenerateAnimationWebP
    else
        runTranscodeAllMP4Files
    fi
}

#*****************************************************

if [ $# -lt 1 ]
then
    runUsage
    exit 1
fi

Input=$1

runMain
#*****************************************************
