#!/bin/bash
#***************************************************************
# brief:
#    parse mp4 files' video/audion info based mp4info tool
#***************************************************************

runUsage()
{
    echo -e "\033[31m ***************************************** \033[0m"
    echo " Usage:"
    echo "    $0  \$OrigintMp4File \$TranscodeMP4File"
    echo -e "\033[31m ***************************************** \033[0m"
}

runInitMP4Info()
{
    let "VideoInfoLineNum = 24"
    let "AudioInfoLineNum = 10"

    let "VideoSampleCount = 0"
    let "AudioSampleCount = 0"
    let "VideoBitRate     = 0"
    let "AudioBitRate     = 0"
    let "VideoDuration    = 0"
    let "AudioDuration    = 0"

    let "MaxValidDiff = 2000"

    VideoTrackInfo="Mp4Info_Video.txt"
    AudioTrackInfo="Mp4Info_Audio.txt"
    MP4Info="mp4info.txt"
}

runParseVideoInfo()
{
    VideoSampleCount=`cat ${VideoTrackInfo} |grep "sample count"  |awk 'BEGIN {FS=" "} {print $3}'`
    VideoBitRate=`cat ${VideoTrackInfo}  |grep "bitrate"  |awk 'BEGIN {FS=" "} {print $3}'`
    VideoDuration=`cat ${VideoTrackInfo} |grep "duration" |awk 'BEGIN {FS=" "} {print $2}' |head -n 1`
}

runParseAudioInfo()
{
    AudioSampleCount=`cat ${AudioTrackInfo} | grep "sample count" | awk 'BEGIN {FS=" "} {print $3}'`
    AudioBitRate=`cat ${AudioTrackInfo}  |grep "bitrate"  | awk 'BEGIN {FS=" "} {print $3}'`
    AudioDuration=`cat ${AudioTrackInfo} |grep "duration" |awk 'BEGIN {FS=" "} {print $2}' |head -n 1`
}

runCheckOneMP4()
{
    if [ -z "${VideoSampleCount}" ] ||  [ -z "${VideoBitRate}" ] ||  [ -z "${VideoDuration}" ]
    then
        echo -e "\033[32m mp4 file video track info is incomplete! \033[0m"
        exit 1
    fi

    if [ -z "${AudioSampleCount}" ] ||  [ -z "${AudioBitRate}" ] ||  [ -z "${AudioDuration}" ]
    then
        echo -e "\033[32m mp4 file audio track info is incomplete! \033[0m"
        exit 1
    fi

    if [ ${VideoSampleCount} -le 0 ] ||  [ ${VideoDuration} -le 0  ]
    then
        echo -e "\033[32m mp4 file video track info is incorrect! \033[0m"
        exit 1
    fi

    if [ ${AudioSampleCount} -le 0 ] ||  [ ${AudioDuration} -le 0  ]
    then
        echo -e "\033[32m mp4 file video track info is incorrect! \033[0m"
        exit 1
    fi
}

runOutputParseInfo()
{
    echo -e "\033[32m ***************************************** \033[0m"
    echo -e "\033[33m ***************************************** \033[0m"
    echo "  Video info                                      "
    echo "  VideoBitRate(kbps):  $VideoBitRate"
    echo "  VideoSampleCount:    $VideoSampleCount"
    echo "  VideoDuration(ms):   $VideoDuration"
    echo -e "\033[34m ***************************************** \033[0m"
    echo "  Audio info                                      "
    echo "  AudioBitRate(kbps):   $AudioBitRate"
    echo "  AudioSampleCount:     $AudioSampleCount"
    echo "  AudioDuration(ms):    $AudioDuration"
    echo -e "\033[32m ***************************************** \033[0m"
}

runCheckOneMP4File()
{
    runInitMP4Info

    mp4info ${MP4File} >${MP4Info}

    egrep -i -A${VideoInfoLineNum} "type: *Video" ${MP4Info} >${VideoTrackInfo}
    egrep -i -A${AudioInfoLineNum} "type: *Audio" ${MP4Info} >${AudioTrackInfo}

    runParseVideoInfo
    runParseAudioInfo
    runOutputParseInfo

    runCheckOneMP4
}

runCheckOriginAndTranscodeMP4File()
{
    MP4File="${OrigintMp4File}"
    runCheckOneMP4File
    let "OriginDuration = ${VideoDuration}"

    MP4File="${OrigintMp4File}"
    runCheckOneMP4File
    let "TranscodeDuration = ${VideoDuration}"

    if [ ${OriginDuration} -ge ${TranscodeDuration} ]; then
        let "DurationDiff = ${OriginDuration} - ${TranscodeDuration}"
    else
        let "DurationDiff = ${TranscodeDuration} - ${OriginDuration}"
    fi

    if [ ${DurationDiff} -gt ${MaxValidDiff} ]; then
        echo -e "\033[31m origin and transcoded duration not matched! \033[0m"
        exit 1
    fi
}

runCheck()
{
    [ ! -e ${OrigintMp4File}   ] && echo -e "\033[31m ${OrigintMp4File} not exist!   \033[0m" && exit 1
    [ ! -e ${TranscodeMP4File} ] && echo -e "\033[31m ${TranscodeMP4File} not exist! \033[0m" && exit 1
}

runPrompt()
{
    echo -e "\033[32m ***************************************** \033[0m"
    echo -e "\033[32m origin and transcoded file check passed! \033[0m"
    echo -e "\033[33m ***************************************** \033[0m"
}

runMain()
{
    runCheck
    runCheckOriginAndTranscodeMP4File

    runPrompt
}

#*****************************************************
if [ $# -lt 2 ]
then
    runUsage
    exit 1
fi

OrigintMp4File=$1
TranscodeMP4File=$2

runMain
#*****************************************************




