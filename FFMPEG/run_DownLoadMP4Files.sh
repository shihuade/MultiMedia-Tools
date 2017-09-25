#!/bin/bash



runInit()
{
    CurrentDir=`pwd`
    MP4FileList="MP4FileIPList.txt"
    OutputDir="${CurrentDir}/MP4FileList"

    mkdir -p ${OutputDir}
}

runPrompt()
{
    echo -e "\033[32m ***************************************** \033[0m"
    echo -e "\033[32m  FileIndex:   ${FileIndex}                \033[0m"
    echo -e "\033[32m  FailedIndex: ${FailedIndex}              \033[0m"
    echo -e "\033[32m  MP4FileName: ${MP4FileName}              \033[0m"
    echo -e "\033[32m  OutputFile:  ${OutputFile}               \033[0m"
    echo -e "\033[32m  MP4FileIP:   ${MP4FileIP}                \033[0m"
    echo -e "\033[32m  Command:     ${Command}                  \033[0m"
    echo -e "\033[32m ***************************************** \033[0m"
}

runDownload()
{
    let "FileIndex   = 0"
    let "FailedIndex = 0"
    while read line
    do
        MP4FileIP=${line}
        MP4FileName=`echo ${MP4FileIP} | awk 'BEGIN {FS="/"} {print $NF}'`
        OutputFile="${OutputDir}/${MP4FileName}"
        MP4Flag=`echo ${MP4FileName} | grep ".mp4"`
        Command="wget ${MP4FileIP}  -O ${OutputFile}"

        [ -z "${MP4Flag}" ] && continue

        runPrompt
        ${Command}
        [ $? -ne 0 ] && echo -e "\033[31m Download failed! \033[0m" && let "FailedIndex +=1" &&continue

        let "FileIndex += 1"

    done <${MP4FileList}
}


runMain()
{
    runInit

    runDownload
}
#******************************************************************
runMain
#******************************************************************

