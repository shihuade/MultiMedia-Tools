#!/bin/bash



runInit()
{
    CurrentDir=`pwd`
    MP4FileList="MP4FileIPList.txt"
    OutputDir="${CurrentDir}/MP4FileList"

    mkdir -p ${OutputDir}c
}

runPrompt()
{
    echo -e "\033[32m ***************************************** \033[0m"
    echo -e "\033[32m  FileIndex:   ${FileIndex}                \033[0m"
    echo -e "\033[32m  MP4FileName: ${MP4FileName}              \033[0m"
    echo -e "\033[32m  OutputFile:  ${OutputFile}               \033[0m"
    echo -e "\033[32m ***************************************** \033[0m"
}

runDownload()
{
    let "FileIndex = 0"
    while read line
    do
        MP4File=${line}
        MP4FileName=`echo ${MP4File} | awk 'BEGIN {FS="/"} {print $NF}'`
        OutputFile="${OutputDir}/${MP4FileName}"
        MP4Flag=`echo ${MP4FileName} | grep ".mp4"`
        [ -z "${MP4Flag}" ] && continue


        wget ${MP4File}  -O ${OutputFile}
        [ $? -ne 0 ] && continue

        runPrompt

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

