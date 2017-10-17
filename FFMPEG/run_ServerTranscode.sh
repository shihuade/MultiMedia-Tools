#!/bin/bash
#***************************************************************
# brief:
#       transcode mp4
#       and generate transcode statistic report
#***************************************************************


runUsage()
{
    echo -e "\033[31m ***************************************** \033[0m"
    echo " Usage:                                                  "
    echo "      $0  \$InputDir  \$Pattern                          "
    echo "      --InputDir: mp4 dir which files will be transcoded "
    echo "      --Pattern: file name pattern                       "
    echo -e "\033[31m ***************************************** \033[0m"
    exit 1
}

runInit()
{
    TranscodePattern="FFTrans"
    MP4CheckScript="./run_CheckTranscodedMP4.sh"

    OutputFileSuffix="${TranscodePattern}_server"

    MP4Option=" -movflags faststart -use_editlist 0 "
    CodecOpts=" -c:a copy -c:v libx264 -profile:v high -level 3.1 "
    x264Opts=" -x264opts scenecut=30:subme=2:trellis=1 "
    x264OptsPlus=" -bf 3 -refs 4 -rc-lookahead 20 -crf 23 -qcomp 0.52 -deblock 0 -nr 500 "

    let "SuccedNum = 0"
    let "FailedNum = 0"
}

runPromptForOneMp4()
{
    echo -e "\033[32m ****************************************************** \033[0m"
    echo -e "\033[32m Mp4File is $Mp4File                                    \033[0m"
    echo -e "\033[32m TransCommand is : $TransCommand                        \033[0m"
    echo -e "\033[32m ****************************************************** \033[0m"
}

runPromptForOneMp4Failed()
{
    echo -e "\033[31m ****************************************************** \033[0m"
    echo -e "\033[31m  Mp4File is ${Mp4File}                                 \033[0m"
    echo -e "\033[31m  Transcode checked failed!                             \033[0m"
    echo -e "\033[31m ****************************************************** \033[0m"
}

runPromptForOneMp4Succeeded()
{
    echo -e "\033[32m ************************************** \033[0m"
    echo -e "\033[32m  ffmpeg transcoded succeeded!          \033[0m"
    echo -e "\033[32m  SuccedNum is : $SuccedNum             \033[0m"
    echo -e "\033[32m ***************************************\033[0m"
}

runPromptSummary()
{
    echo -e "\033[32m ************************************************** \033[0m"
    echo -e "\033[32m  All MP4 files have been transcoded!               \033[0m"
    echo -e "\033[32m  SuccedNum is ${SuccedNum}                         \033[0m"
    echo -e "\033[32m  FailedNum is ${FailedNum}                         \033[0m"
    echo -e "\033[32m ************************************************** \033[0m"
}

runCheckTranscodeMP4()
{
    MP4CheckCommand="${MP4CheckScript} ${Mp4File} ${OutputFile}"
    echo "Parse command is $MP4CheckCommand"
    ${MP4CheckCommand}
    if [ $? -ne 0 ]; then
        runPromptForOneMp4Failed
        let "FailedNum += 1"
        return 1
    fi

    runPromptForOneMp4Succeeded
    let "SuccedNum += 1"
    return 0
}

runTranscodeAllMP4()
{
    for Mp4File in ${InputDir}/*${Pattern}*.mp4
    do
        #for transcoded files, skip
        OriginFlag=`echo "$Mp4File" | grep "${TranscodePattern}"`
        [ -z "${OriginFlag}" ] || continue

        OutputFile="${Mp4File}_${OutputFileSuffix}.mp4"
        TransCommand="ffmpeg -xerror -i ${Mp4File} ${CodecOpts} ${x264Opts} ${x264OptsPlus} ${MP4Option} -y ${OutputFile}"

        runPromptForOneMp4

        ${TransCommand}
        if [ $? -ne 0 ]; then
            echo -e "\033[31m  ffmpeg transcoded failed! \033[0m"
            let "FailedNum += 1"
            continue
        fi
        runCheckTranscodeMP4
    done
}

runCheck()
{
    [ ! -d ${Input} ] && echo "Input dir doest not exist, please double check" && runUsage
}

runMain()
{
    runCheck
    runInit

    runTranscodeAllMP4
    runPromptSummary
}

#*****************************************************

if [ $# -lt 1 ]
then
    runUsage
    exit 1
fi

InputDir=$1
Pattern=$2

runMain
#*****************************************************




