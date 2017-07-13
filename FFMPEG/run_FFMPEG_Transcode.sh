#!/bin/bash


runUsage

runInit()
{
    TranscodePattern="ffmpeg_trans"

}

runParseOriginFile()
{

Track 1:
flags:        1 ENABLED
id:           1
type:         Audio
duration: 13833 ms
language: und
media:
sample count: 598
timescale:    44100
duration:     612352 (media timescale units)
duration:     13886 (ms)
bitrate (computed): 83.506 Kbps
Sample Description 0
Coding:      mp4a (MPEG-4 Audio)
Stream Type: Audio
Object Type: MPEG-4 Audio
Max Bitrate: 128000
Avg Bitrate: 128000
Buffer Size: 6144
Codecs String: mp4a.40.2
MPEG-4 Audio Object Type: 2 (AAC Low Complexity)
MPEG-4 Audio Decoder Config:
Sampling Frequency: 44100
Channels: 2
Sample Rate: 44100
Sample Size: 16
Channels:    2
Track 2:


type:         Video
duration: 13866 ms
language: und
media:
sample count: 416
timescale:    600
duration:     8320 (media timescale units)
duration:     13867 (ms)
bitrate (computed): 1991.797 Kbps
display width:  540.000000
display height: 960.000000
frame rate (computed): 30.000
Sample Description 0
Coding:      avc1 (H.264)
Width:       540
Height:      960
Depth:       24
AVC Profile:          100 (High)
AVC Profile Compat:   0
AVC Level:            31
AVC NALU Length Size: 4
AVC SPS: [2764001fac56c0881e7bd0]
AVC PPS: [28ee3cb0]
Codecs String: avc1.64001F

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
    let "VideoCompreRate  = 0"

    Profile=""
    Level=""

    VideoTrackInfo="Mp4Info_Video.txt"
    AudioTrackInfo="Mp4Info_Audio.txt"
}

runParseVideoInfo()
{
    VideoSampleCount=`cat ${VideoTrackInfo} | grep "sample count"  | awk 'BEGIN {FS=" "} {print $2}'`
    #kbps
    VideoBitRate=`cat ${VideoTrackInfo}     | grep "bitrate"       | awk 'BEGIN {FS=" "} {print $3}'`

    VideoFPS=`cat ${VideoTrackInfo}         | grep "frame rate"    | awk 'BEGIN {FS=" "} {print $4}'`
    VideoWidth=`cat ${VideoTrackInfo}       | grep "Width"         | awk 'BEGIN {FS=" "} {print $2}'`
    VideoHeight=`cat ${VideoTrackInfo}      | grep "Height"        | awk 'BEGIN {FS=" "} {print $2}'`

    Profile=`cat ${VideoTrackInfo} | grep "AVC Profile:" | awk 'BEGIN {FS="("} {print $2}' | awk 'BEGIN {FS=")"} {print $1}'`
    Level=`cat ${VideoTrackInfo} | grep "AVC Level:"   | awk 'BEGIN {FS=" "} {print $2}'`
}

runParseAudioInfo()
{
    AudioSampleCount=`cat ${AudioTrackInfo} | grep "sample count" | awk 'BEGIN {FS=" "} {print $2}'`
    #kbps
    AudioBitRate=`cat ${AudioTrackInfo}     | grep "bitrate"      | awk 'BEGIN {FS=" "} {print $2}'`
    AudioDuration=`cat ${AudioTrackInfo}    | grep "duration"     | awk 'BEGIN {FS=" "} {print $2}'`
}

runCalculateInfo()
{
    #bytes
    MP4Size=`ls -l ${file} | awk '{print $5}'`

    FrameCompressedRatio=`echo  "scale=2; ${FrameCompressedRatio} / ${DataNum}" | bc`



}

runParseOriginFile()
{


egrep -i -A${VideoInfoLineNum} "type: *Video" mp4info.txt >${VideoTrackInfo}
egrep -i -A${AudioInfoLineNum} "type: *Audio" mp4info.txt >${AudioTrackInfo}


}



runTranscode()
{

    for file in ${InputDir}/*.mp4
    do
        OriginFlag=`echo "$file" | grep ${TranscodePattern}`
        [ -z "${OriginFlag}" ] || continue

        OutputFile="${file}_${TranscodePattern}_${Pattern}.mp4"
        TransCommand="ffmpeg -i $file -c:a copy -c:v libx264 -profile:v high -level 3.1"
        TransCommand="$TransCommand -crf 24 ${x264Params} -y $OutputFile"
        echo "****************************************"
        echo "  file is $file"
        echo "  TransCommand is : $TransCommand"
        echo "  addition enc param is: ${x264Params}"
        echo "****************************************"

        ${TransCommand}

    done


}


runMain()
{

runInit
runTranscode


}

InputDir=$1
x264Params=$2
Pattern=$3

runMain




