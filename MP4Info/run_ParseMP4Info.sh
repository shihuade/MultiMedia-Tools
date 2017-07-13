#!/bin/bash
#***************************************************************
#  parse mp4 files' video/audion info based mp4info tool
#***************************************************************

runUsage()
{
    echo "*****************************************"
    echo " Usage:"
    echo "    $0  \$InputMp4File  \$OutputFile"
    echo "    $0  \$InputMp4Dir   \$OutputFile"
    echo " example:"
    echo "    $0   test.mp4 test.mp4.csv"
    echo "*****************************************"
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

    let "VideoSize        = 0"
    let "AudioSize        = 0"
    let "VideoRatio       = 0"
    let "AudioRatio       = 0"
    let "MP4Size          = 0"

    let "VideoWidth       = 0"
    let "VideoHeight      = 0"
    let "VideoFPS         = 0"
    let "VideoRawSize     = 0"
    let "VideoCompreRate  = 0"

    Profile=""
    Level=""

    VideoTrackInfo="Mp4Info_Video.txt"
    AudioTrackInfo="Mp4Info_Audio.txt"
    MP4Info="mp4info.txt"
}

runInitOutputInfo()
{
    #0
    HeadLineBasic="File, size(MBs),VSize(MB),ASize(MBs),VRatio(%),ARatio(%),VDuration,ADuration"
    #8
    HeadLineAudio="SampeC, BR(kbps)"
    #10
    HeadLineVideo="Profile, Level, PicW, PicH,FPS,FrmNum,BR(kbps),CR"

    HeadLine="${HeadLineBasic}, ${HeadLineAudio}, ${HeadLineVideo}"
}

runParseVideoInfo()
{
    VideoSampleCount=`cat ${VideoTrackInfo} | grep "sample count"  | awk 'BEGIN {FS=" "} {print $3}'`
    #kbps
    VideoBitRate=`cat ${VideoTrackInfo}     | grep "bitrate"       | awk 'BEGIN {FS=" "} {print $3}'`
    VideoDuration=`cat ${VideoTrackInfo}    | grep "duration"      | awk 'BEGIN {FS=" "} {print $2}' | head -n 1`

    VideoFPS=`cat ${VideoTrackInfo}         | grep "frame rate"    | awk 'BEGIN {FS=" "} {print $4}'`
    VideoWidth=`cat ${VideoTrackInfo}       | grep "Width"         | awk 'BEGIN {FS=" "} {print $2}'`
    VideoHeight=`cat ${VideoTrackInfo}      | grep "Height"        | awk 'BEGIN {FS=" "} {print $2}'`

    Profile=`cat ${VideoTrackInfo} | grep "AVC Profile:" | awk 'BEGIN {FS="("} {print $2}' | awk 'BEGIN {FS=")"} {print $1}'`
    Level=`cat ${VideoTrackInfo} | grep "AVC Level:"   | awk 'BEGIN {FS=" "} {print $2}'`
}

runParseAudioInfo()
{
    AudioSampleCount=`cat ${AudioTrackInfo} | grep "sample count" | awk 'BEGIN {FS=" "} {print $3}'`
    #kbps
    AudioBitRate=`cat ${AudioTrackInfo}     | grep "bitrate"      | awk 'BEGIN {FS=" "} {print $3}'`
    AudioDuration=`cat ${AudioTrackInfo}    | grep "duration"     | awk 'BEGIN {FS=" "} {print $2}' | head -n 1`
}

runCalculateVideoInfo()
{
    #MBbyts
    MP4Size=`echo  "scale=2; ${MP4Size} / 1024 /1024" | bc`
    FrameSize=`echo  "scale=2; ${VideoWidth} * ${VideoHeight} * 1.5" | bc`

    VideoRawSize=`echo  "scale=2; ${VideoSampleCount} * ${FrameSize} / 1024 /1024 " | bc`
    VideoSize=`echo  "scale=2; ${VideoBitRate} * ${VideoDuration} /1000 / 1024 / 8" | bc`

    VideoCompreRate=`echo  "scale=2; ${VideoRawSize} / ${VideoSize}" | bc`
    VideoRatio=`echo  "scale=2; ${VideoSize} / ${MP4Size} * 100" | bc`

echo "VideoRawSize is --$VideoRawSize--"
echo "VideoSize is --$VideoSize--"

}

runCalculateAudioInfo()
{
    AudioSize=`echo  "scale=2; ${AudioBitRate} * ${AudioDuration} /1000 / 1024 / 8" | bc`
    AudioRatio=`echo  "scale=2; ${AudioSize} / ${MP4Size} * 100" | bc`
}

runCVSOutputInfoForOneFile()
{
    MP4Basic="$MP4File, $MP4Size, $VideoSize, $AudioSize, $VideoRatio, $AudioRatio, $VideoDuration, $AudioDuration"
    AudioData="$AudioSampleCount, $AudioDuration"
    VideoData="$Profile, $Level, $VideoWidth, $VideoHeight, $VideoFPS, $VideoSampleCount, $VideoBitRate, $VideoCompreRate"

   MP4Data="${MP4Basic}, ${AudioData}, ${VideoData}"
}

runOutputParseInfo()
{
    echo "**************************************************"
    echo "  file is:             $MP4File"
    echo "  MP4Size(MBs):        $MP4Size"
    echo "**************************************************"
    echo "  Video info                                      "
    echo "     Profile: $Profile  Level: $Level             "
    echo "     $VideoWidth x ${VideoHeight}  FPS: $VideoFPS "
    echo "     VideoSize(MBs): $VideoSize    $VideoRatio%   "
    echo "**************************************************"
    echo "  VideoBitRate(kbps):  $VideoBitRate"
    echo "  VideoCompreRate:     $VideoCompreRate"
    echo "  VideoSampleCount:    $VideoSampleCount"
    echo "  VideoDuration(ms):   $VideoDuration"
    echo "**************************************************"
    echo "  Audio info                                      "
    echo "     AudioSize(MBs): $AudioSize    $AudioRatio%   "
    echo "**************************************************"
    echo "  AudioBitRate(kbps):   $AudioBitRate"
    echo "  AudioSampleCount:     $AudioSampleCount"
    echo "  AudioDuration(ms):    $AudioDuration"
    echo "**************************************************"
}

runParseOneMp4File()
{
    echo "**************************************************"
    echo " Parsing mp4 file ..."
    echo "     MP4File is:  ${MP4File}"
    echo "**************************************************"

    runInitMP4Info

    #bytes
    MP4Size=`ls -l ${MP4File} | awk '{print $5}'`

    mp4info ${MP4File} >${MP4Info}

    egrep -i -A${VideoInfoLineNum} "type: *Video" ${MP4Info} >${VideoTrackInfo}
    egrep -i -A${AudioInfoLineNum} "type: *Audio" ${MP4Info} >${AudioTrackInfo}

    runParseVideoInfo
    runParseAudioInfo
    runCalculateVideoInfo
    runCalculateAudioInfo
    runCVSOutputInfoForOneFile
    runOutputParseInfo
}

runParseAllMP4Files()
{
    if [ -e ${Input} ]
    then
        MP4File=${Input}
        runParseOneMp4File

        echo ${MP4Data} >${OutputFile}

        return 0
    fi

    runInitOutputInfo
    echo "HeadLine">${OutputFile}

    for MP4File in ${Input}/*.mp4
    do
        runParseOneMp4File
        echo ${MP4Data} >>${OutputFile}

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

    [ -z ${OutputFile} ] && OutputFile="MP4Info.csv"
}

runMain()
{
    runCheck
    runParseAllMP4Files
}

#*****************************************************
if [ $# -lt 1 ]
then
    runUsage
    exit 1
fi

Input=$1
OutputFile=$2

runMain
#*****************************************************




