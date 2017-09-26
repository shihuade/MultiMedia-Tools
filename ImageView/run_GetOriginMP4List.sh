#!/bin/bash
#********************************************************************************
#  get origin mp4 file list
#
#********************************************************************************

runUsage()
{
    echo -e "\033[31m ***************************************************** \033[0m"
    echo "   Usage:                                                         "
    echo "      $0  \$InputMp4Dir \${OrinMp4List}                           "
    echo "      --InputMp4Dir:  image files which will be view via browser  "
    echo "      --OrinMp4List:  origin mp4 file list                        "
    echo -e "\033[31m ***************************************************** \033[0m"
}


runGetOriginMp4List()
{
    #*****************************************************
    #MP4Name format for ffmpeg transcoded may looks like:
    # ABC.mp4
    # ABC.mp4_FFTRANS_crf21.mp4
    # ABC.mp4_FFTRANS_crf23.mp4
    #*****************************************************

    PreName=""
    let "OriginIdx = 0"
    for mp4 in ${InputMp4Dir}/*.mp4
    do

        Mp4Name=`basename ${mp4}`
        Mp4Name=`echo ${Mp4Name} | awk 'BEGIN {FS=".mp4"} {print $1}'`

        [ "$Mp4Name" = "$PreName" ] && continue

        echo "${OriginIdx} ${Mp4Name}.mp4 " >>${OrinMp4List}
        PreName="${Mp4Name}"
        let "OriginIdx += 1"
    done

    echo -e "\033[32m ***************************************** \033[0m"
    echo -e "\033[32m   MP4Num      is: ${OriginIdx}            \033[0m"
    echo -e "\033[32m   InputMp4Dir is: ${InputMp4Dir}          \033[0m"
    echo -e "\033[32m   output list is: ${OrinMp4List}          \033[0m"
    echo -e "\033[32m   Origin file list:                       \033[0m"
    cat ${OrinMp4List}
    echo -e "\033[32m ***************************************** \033[0m"
}

runCheck()
{
    if [ ! -d ${InputMp4Dir} ]
    then
        echo "Image dir not exist, please double check"
        runUsage
        exit 1
    fi

    [ -e ${OrinMp4List} ] && rm -f ${OrinMp4List}
}

runMain()
{
    runCheck

    runGetOriginMp4List
}

#*************************************************************************************
if [ $# -lt 2 ]
then
    runUsage
    exit 1
fi

InputMp4Dir=$1
OrinMp4List=$2

runMain
#*************************************************************************************

