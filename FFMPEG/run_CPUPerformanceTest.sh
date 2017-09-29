#!/bin/bash


runInit()
{
    CodecParam=" -c:a copy -c:v libx264 -profile:v high -level 3.1 "
    x264Arg01=" -x264opts scenecut=30:subme=0:trellis=0:threads=4 -bf 2 -refs 2 "
    x264Arg02=" -x264opts scenecut=30:subme=0:trellis=0:threads=3 -bf 2 -refs 2 "
    x264Param=" -rc-lookahead 10 -crf 22 -qcomp 0.54 -deblock 0 -nr 450"
    PluseParam="-threads 4 -movflags faststart -use_editlist 0 -y"

    InputMP4="/Users/huade/Desktop/CopyVideo/Import-Copy-04.mp4"
    OutputMP4="/Users/huade/Desktop/CopyVideo/Import-Copy-04.mp4_orgdesign.mp4"

    Command1="ffmpeg -i ${InputMP4} ${CodecParam} ${x264Arg01} ${x264Param} ${PluseParam} ${OutputMP4}"
    Command2="ffmpeg -i ${InputMP4} ${CodecParam} ${x264Arg02} ${x264Param} ${PluseParam} ${OutputMP4}"

    let "LoopNum   = 30"
    let "SleepTime = 20"
}

runPrompt()
{
    echo -e "\033[32m ***************************************** \033[0m"
    echo -e "\033[32m Command is ${Command}                     \033[0m"
    echo -e "\033[32m ***************************************** \033[0m"
}

runCPUTest()
{
    for((i=0; i<${LoopNum}; i++))
    do
        echo -e "\033[33m ***************************************** \033[0m"
        echo -e "\033[33m Loop index : ${i}                         \033[0m"
        echo -e "\033[33m Label is   : ${Label}                     \033[0m"
        echo -e "\033[33m Command is : ${Command}                   \033[0m"
        echo -e "\033[33m ***************************************** \033[0m"
        ${Command} 2>Log_CPUTest.txt

    done
}

runMain()
{
    runInit

    Command="${Command1}"
    Label="Command1"
    runPrompt
    runCPUTest

    sleep ${SleepTime}

    Command="${Command2}"
    Label="Command2"
    runPrompt
    runCPUTest
}

#***********************************************
runMain



