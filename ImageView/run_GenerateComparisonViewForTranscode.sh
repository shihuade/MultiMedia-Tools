#!/bin/bash
#********************************************************************************
#  copy image from given dir, and preparing for comarision
#
#     ViewModule/index.html will browse image from
#     ViewModule/images
#
#********************************************************************************

runUsage()
{
    echo -e "\033[31m ***************************************************** \033[0m"
    echo "   Usage:                                                         "
    echo "      $0  \$InputMp4Dir \${Pattern01} \${Pattern02}               "
    echo "      --InputMp4Dir:  image files which will be view via browser  "
    echo "      --Pattern0:  origin image file patern                       "
    echo "      --Pattern02: comparison image file patern                   "
    echo -e "\033[31m ***************************************************** \033[0m"
}

runInit()
{
    CurrentDir=`pwd`
    ImageDirForView="${CurrentDir}/ViewModule/images"

    [ -d ${ImageDirForView} ] && rm -rf ${ImageDirForView}
    mkdir -p ${ImageDirForView}

    let "PicNum    = 10"
    let "ImageIdx  = 0"
    let "MP4Idx    = 0"
    let "MP4Num    = 0"

    declare -a aOriginMP4List

    OrinMp4List="${CurrentDir}/Log_OriginMp4List.csv"
    [ -e ${OrinMp4List} ]        && rm ${OrinMp4List}

    ImageInfoFile="${CurrentDir}/Log_ImageInfo.csv"
    HeadLine="Index, FileName, FileSize, MP4, MP4Index, Duration, PicIndex, TimeStamp, Format"
    echo ${HeadLine} >${ImageInfoFile}
}

runGetOriginMp4List()
{
    ./run_GetOriginMP4List.sh  "${InputMp4Dir}" "${OrinMp4List}"
    aOriginMP4List=(`cat ${OrinMp4List}`)
    MP4Num=${#aOriginMP4List[@]}
}

runPareseTimeStampInfo()
{
    TimeInfoLog="Log_MP4TimeInfo.txt"
    ./run_GetMP4TimeInfo.sh "${MP4File01}" "${PicNum}" "${TimeInfoLog}"

    DurationInfo=`cat ${TimeInfoLog} | head -n 1 | awk '{print $1}'`
    FrameInterval=`cat ${TimeInfoLog} | head -n 1 | awk '{print $2}'`
}

runUpdateImageInfo()
{
    [ -e ${OutputImage01} ] && FileSize01=`ls -l $OutputImage01 | awk '{print $5}'`
    [ -e ${OutputImage02} ] && FileSize02=`ls -l $OutputImage02 | awk '{print $5}'`

    BasicMP4Info="$MP4Idx, $DurationInfo, $PicIdx, $TimeStamp, $Format"
    MP4FileInfo01="$ImageIdx, $OutputImage01, ${FileSize01}, $MP4File01, ${BasicMP4Info}"
    MP4FileInfo02="$ImageIdx, $OutputImage02, ${FileSize02}, $MP4File02, ${BasicMP4Info}"

    echo "${MP4FileInfo01}" >>${ImageInfoFile}
    echo "${MP4FileInfo02}" >>${ImageInfoFile}
}

runParseOneComparisonPictureFromMP4()
{
    OutputImage01="${ImageDirForView}/${ImageIdx}.jpeg"
    OutputImage02="${ImageDirForView}/${ImageIdx}-02.jpeg"

    ./run_ParseOneImageFromMP4.sh "${MP4File01}" "${OutputImage01}" "${TimeStamp}"
    ./run_ParseOneImageFromMP4.sh "${MP4File02}" "${OutputImage02}" "${TimeStamp}"
}

runCapturePictureFromMP4()
{
    let "PicIdx = 0"
    for((j=0; j< ${PicNum}; j++))
    do
        TimeStamp=`echo  "scale=2; ${FrameInterval} * $j " | bc`
        IntNum=`echo ${TimeStamp} | awk 'BEGIN {FS="."} {print $1}'`
        [ "${IntNum}" = "" ] && TimeStamp="0${TimeStamp}"

        runParseOneComparisonPictureFromMP4
        [ $? -ne 0 ] && echo "runParseOneComparisonPictureFromMP4 failed!" && return 1

        let "PicIdx   += 1"
        let "ImageIdx += 1"
    done
}

runPromptForOneMP4()
{
    echo -e "\033[34m ********************************* \033[0m"
    echo -e "\033[34m MP4Idx    is: ${MP4Idx}           \033[0m"
    echo -e "\033[34m MP4File01 is: ${MP4File01}        \033[0m"
    echo -e "\033[34m MP4File02 is: ${MP4File02}        \033[0m"
    echo -e "\033[34m ********************************* \033[0m"
}

runParseAllComparisonMp4File()
{
    for((i=0; i<${MP4Num}; i++))
    do

        OriginFile=${aOriginMP4List[$i]}
        MP4File01=`ls ${InputMp4Dir}/*.mp4 | grep ${OriginFile} |  grep ${Pattern1} | head -n 1`
        [ -z "$MP4File01" ] && echo "no match file for comparison" && continue

        MP4File02=`ls ${InputMp4Dir}/*.mp4 | grep ${OriginFile} |  grep ${Pattern2} | head -n 1`
        [ -z "$MP4File02" ] && echo "no match file for comparison" && continue

        runPromptForOneMP4
        runPareseTimeStampInfo
runCapturePictureFromMP4
        [ $? -ne 0 ] && echo "runCapturePictureFromMP4 failed!" && continue

        let "MP4Idx   += 1"
    done <${OrinMp4List}
}

runInputPromt()
{
    echo -e "\033[32m ******************************************\033[0m"
    echo -e "\033[32m InputMp4Dir     is: ${InputMp4Dir}        \033[0m"
    echo -e "\033[32m ImageDirForView is: ${ImageDirForView}    \033[0m"
    echo -e "\033[32m Pattern1        is: ${Pattern1}           \033[0m"
    echo -e "\033[32m Pattern2        is: ${Pattern2}           \033[0m"
    echo -e "\033[32m ******************************************\033[0m"
}

runCheck()
{
    if [ ! -d ${InputMp4Dir} ]
    then
        echo "Image dir not exist, please double check"
        runUsage
        exit 1
    fi
}


runMain()
{
    runInit

    runCheck

    runInputPromt

    runGetOriginMp4List
    runParseAllComparisonMp4File

}

#*************************************************************************************
if [ $# -lt 3 ]
then
    runUsage
    exit 1
fi

InputMp4Dir=$1
Pattern1=$2
Pattern2=$3

runMain
#*************************************************************************************

