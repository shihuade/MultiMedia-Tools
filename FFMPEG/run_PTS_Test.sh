#!/bin/bash


runInint()
{
    MP4Dir="./montage-duet"
    InputMP4File01="/Users/huade/Desktop/Montage-Test/Camera-copy-01.mp4"
    InputMP4File02="/Users/huade/Desktop/Montage-Test/Camera-copy-03.mp4"

    MP4Dir=`dirname ${InputMP4File01}`
}

runPromptCMD()
{
    echo -e "\033[31m ***************************************** \033[0m"
    echo -e "\033[31m   PTSCMD is ${PTSCMD}                     \033[0m"
    echo -e "\033[31m ***************************************** \033[0m"
}

runPTSTest()
{
    PTSOption="2.0*PTS"
    OutputFile="${InputMP4File01}_PTS_${PTSOption}.mp4"

    PTSCMD="ffmpeg  -i ${InputMP4File01} -an -c:v libx264 -x264opts pic-struct=1 -filter:v setpts=${PTSOption} -y ${OutputFile}"

    runPromptCMD

    ${PTSCMD}
}

runMain()
{
    runInint

    runPTSTest
}

#**************
runMain

