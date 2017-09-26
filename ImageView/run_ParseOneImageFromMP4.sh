#!/bin/bash
#********************************************************************************
#  parse one image from mp4
#
#     ViewModule/index.html will browse image from
#     ViewModule/images
#
#********************************************************************************

runUsage()
{
    echo -e "\033[31m ***************************************************** \033[0m"
    echo "   Usage:                                                        "
    echo "      $0  \$InputMp4 \${OutputImage} \${TimeStamp}               "
    echo -e "\033[31m ***************************************************** \033[0m"
}

runPrompt()
{
    echo -e "\033[32m ****************************************\033[0m"
    echo -e "\033[33m TimeStamp      is: ${TimeStamp}         \033[0m"
    echo -e "\033[32m OutputImage    is: ${OutputImage}       \033[0m"
    echo -e "\033[34m Command        is: ${Command}           \033[0m"
    echo -e "\033[32m *************************************** \033[0m"
}

runGetOnePictureFromMP4()
{
    #file from MP4File01
    Format="image2"
    TempFFMPEGImageLog="Log_FFMPEG_ImageParse.txt"
    Command="ffmpeg -ss ${TimeStamp} -i ${InputMp4} -an  -vframes 1 -f ${Format} -y ${OutputImage}"

    $Command  2>>${TempFFMPEGImageLog}
    [ $? -ne 0 ] && "runGetOnePictureFromMP4 failed!" && exit 1
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
    runGetOnePictureFromMP4
    runPrompt
}

#*************************************************************************************
if [ $# -lt 3 ]
then
    runUsage
    exit 1
fi

InputMp4=$1
OutputImage=$2
TimeStamp=$3

runMain
#*************************************************************************************

