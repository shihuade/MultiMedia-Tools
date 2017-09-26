#!/bin/bash
#********************************************************************************
#  get mp4 time info
#
#********************************************************************************

runUsage()
{
    echo -e "\033[31m ***************************************************** \033[0m"
    echo "   Usage:                                                         "
    echo "      $0  \$InputMp4 \${FrameNum} \${TimeInfoLog}                 "
    echo "      --InputMp4:    input mp4 file                               "
    echo "      --FrameNum:    num pic for calculating interval time        "
    echo "      --TimeInfoLog: comparison image file patern                 "
    echo -e "\033[31m ***************************************************** \033[0m"
}

runPareseTimeStampInfo()
{
    # get video duration and calculate 1/8 timestamp
    # Duration: 00:00:13.95, start: 0.000000, bitrate: 2644 kb/s
    #*************************************************************************
    CheckMP4="${InputMp4}"
    TranscodeLog="Log_temp.txt"
    ffmpeg -i  ${CheckMP4} -c copy -y ${CheckMP4}_copy.mp4 2>${TranscodeLog}
    rm -f ${CheckMP4}_copy.mp4

    DurationInfo=`cat ${TranscodeLog} | grep "Duration" | awk '{print $2}'`

    Minutes=`echo $DurationInfo | awk 'BEGIN {FS=":"} {print $2}' `
    Seconds=`echo $DurationInfo | awk 'BEGIN {FS=":"} {print $3}'|awk 'BEGIN {FS=","} {print $1}' `
    DurationInSeconds=`echo  "scale=2; 60 * ${Minutes} + $Seconds " | bc`
    FrameInterval=`echo "scale=2; ${DurationInSeconds} / ${FrameNum} " | bc`

    echo "${DurationInSeconds}  ${FrameInterval} " >${TimeInfoLog}
}

runPrompt()
{
    echo -e "\033[33m ***************************************** \033[0m"
    echo -e "\033[33m DurationInfo      is: ${DurationInfo}     \033[0m"
    echo -e "\033[33m DurationInSeconds is: ${DurationInSeconds}\033[0m"
    echo -e "\033[33m FrameInterval     is: ${FrameInterval}    \033[0m"
    echo -e "\033[33m ***************************************** \033[0m"
}

runCheck()
{
    if [ ! -e ${InputMp4} ]
    then
        echo "mp4 file not exist, please double check"
        runUsage
        exit 1
    fi
}

runMain()
{
    runCheck

    runPareseTimeStampInfo

    runPrompt
}

#*************************************************************************************
if [ $# -lt 3 ]
then
    runUsage
    exit 1
fi

InputMp4=$1
FrameNum=$2
TimeInfoLog=$3

runMain
#*************************************************************************************

