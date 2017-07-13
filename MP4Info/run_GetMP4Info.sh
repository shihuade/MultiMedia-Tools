#!/bin/bash
#******************************************************************
#
#   MP4Parser, install and refer to:
#              http://atomicparsley.sourceforge.net/
#
#   mp4info, please download and install before running this script
#
#******************************************************************

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
        mp4info ${file}
        MP4Parser ${file} -T
        echo "*******************************************************"

    done
}


runMoovFastStart()
{
    for file in ${MP4Dir}/*.mp4
    do
        Command="ffmpeg -i $file -c copy -movflags faststart ${file}_moov.mp4 -y"
        echo "*******************************************************"
        echo "   moov faststart operation"
        echo "       ${file}"
        echo "   ${Command}"
        echo "*******************************************************"
        ${Command}
        echo "*******************************************************"
    done
}

runMain()
{
    runInit
    runCheck

#runMoovFastStart
    runParseMP4Info >>${LogFile}
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


