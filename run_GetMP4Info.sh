#!/bin/bash


runInit()
{
    MP4InfoLog="AllMP4FilesInfo.txt"
}

runCheck()
{
    if [ ! -d ${MP4Dir} ]
    then
        echo "MP4Dir ${MP4Dir} does not exist, please double check!"
        exit 1
    fi

    if [ -z ${LogFile} ]
    then
        LogFile=${MP4InfoLog}
        echo "MP4InfoLog is ${MP4InfoLog}"
    fi

    date > ${LogFile}
}

runParseMP4Info()
{

    for file in ${MP4Dir}/*.mp4
    do
        echo "*******************************************************"
        echo "   mp4 info parser for file: "
        echo "       ${file}"
        echo "*******************************************************"
        mp4info ${file} >>${LogFile}
        MP4Parser ${file} -T >>${LogFile}
        echo "*******************************************************"

    done
}

runMain()
{
    runInit
    runCheck
    runParseMP4Info
}

if [ $# -lt 1 ]
then
    echo "*******************************************************"
    echo "    usage: "
    echo "        $0 \${MP4Dir} \${LogFile}"
    echo "*******************************************************"

    exit 1
fi

MP4Dir=$1
LogFile=$2


runMain


