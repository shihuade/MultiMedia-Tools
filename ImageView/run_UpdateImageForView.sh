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
    let "OutPicW   = 1080"
    let "OutPicH   = 1920"
    let "ImageIdx  = 0"
    let "MP4Idx    = 0"

    Format="image2"

    OrinMp4List="${CurrentDir}/Log_OriginMp4List.csv"
    TempFFMPEGImageLog="${CurrentDir}/Log_FFMPEG_ImageParse.txt"
    TranscodeLog="${CurrentDir}/Log_FFMPEG_Transcode.txt"

    [ -e ${OrinMp4List} ]        && rm ${OrinMp4List}
    [ -e ${TempFFMPEGImageLog} ] && rm ${TempFFMPEGImageLog}

    ImageInfoFile="${CurrentDir}/Log_ImageInfo.csv"

    HeadLine="Index, FileName, FileSize, MP4, MP4Index, Duration, PicIndex, TimeStamp, Format"

    echo ${HeadLine} >${ImageInfoFile}
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
        echo "${OriginIdx} ${Mp4Name}.mp4 " >>${OrinMp4List}
        echo "${OriginIdx} ${Mp4Name}.mp4 " >>${OrinMp4List}
        echo "${OriginIdx} ${Mp4Name}.mp4 " >>${OrinMp4List}
        echo "${OriginIdx} ${Mp4Name}.mp4 " >>${OrinMp4List}

        PreName="${Mp4Name}"
        let "OriginIdx += 1"
    done

    echo -e "\033[32m ***************************************** \033[0m"
    echo -e "\033[32m   Origin file num is: ${OriginIdx}        \033[0m"
    echo -e "\033[32m   Origin file list:                       \033[0m"
    cat ${OrinMp4List}
    echo -e "\033[32m ***************************************** \033[0m"
}

runPareseTimeStampInfo()
{
    # get video duration and calculate 1/8 timestamp
    # Duration: 00:00:13.95, start: 0.000000, bitrate: 2644 kb/s
    #*************************************************************************
    CheckMP4="${MP4File01}"
    ffmpeg -i  ${CheckMP4} -c copy -y ${CheckMP4}_copy.mp4 2>${TranscodeLog}
    rm -f ${CheckMP4}_copy.mp4

    DurationInfo=`cat ${TranscodeLog} | grep "Duration" | awk '{print $2}'`


    Minutes=`echo $DurationInfo | awk 'BEGIN {FS=":"} {print $2}' `
    Seconds=`echo $DurationInfo | awk 'BEGIN {FS=":"} {print $3}'|awk 'BEGIN {FS=","} {print $1}' `
    DurationInSeconds=`echo  "scale=2; 60 * ${Minutes} + $Seconds " | bc`
    FrameInterval=`echo  "scale=2; ${DurationInSeconds} / ${PicNum} " | bc`

    echo -e "\033[33m ***************************************** \033[0m"
    echo -e "\033[33m DurationInfo      is: ${DurationInfo}     \033[0m"
    echo -e "\033[33m DurationInSeconds is: ${DurationInSeconds}\033[0m"
    echo -e "\033[33m FrameInterval     is: ${FrameInterval}    \033[0m"
    echo -e "\033[33m ***************************************** \033[0m"
}

runUpdateImageInfo()
{
    [ -e ${OutputImage01} ] && FileSize01=`ls -l $OutputImage01 | awk '{print $5}'`
    [ -e ${OutputImage02} ] && FileSize02=`ls -l $OutputImage02 | awk '{print $5}'`

    BasicMP4Info="$MP4Idx, $DurationInfo, $PicIdx, $TimeStamp, $Format"
    MP4FileInfo01="$ImageIdx, $OutputImage01, ${FileSize01}, $MP4File01, ${BasicMP4Info}"
    MP4FileInfo02="$ImageIdx, $OutputImage02, ${FileSize02},$MP4File02, ${BasicMP4Info}"

    echo "${MP4FileInfo01}" >>${ImageInfoFile}
    echo "${MP4FileInfo02}" >>${ImageInfoFile}
}

runParseOneComparisonPictureFromMP4()
{
    #file from MP4File01
    OutputImage01="${ImageDirForView}/${ImageIdx}.jpg"
    Command01="ffmpeg -ss ${TimeStamp} -i ${MP4File01} -an  -vframes 1 -f ${Format} -y ${OutputImage01}"

    #file from MP4File01
    OutputImage02="${ImageDirForView}/${ImageIdx}-02.jpg"
    Command02="ffmpeg -ss ${TimeStamp} -i ${MP4File02} -an  -vframes 1 -f ${Format} -y ${OutputImage02}"

    echo -e "\033[32m ****************************************\033[0m"
    echo -e "\033[33m PicIdx         is: ${PicIdx}            \033[0m"
    echo -e "\033[33m TimeStamp      is: ${TimeStamp}         \033[0m"
    echo -e "\033[32m OutputImage01  is: ${OutputImage01}     \033[0m"
    echo -e "\033[32m OutputImage02  is: ${OutputImage02}     \033[0m"
    echo -e "\033[34m Command01      is: ${Command01}         \033[0m"
    echo -e "\033[34m Command02      is: ${Command02}         \033[0m"
    echo -e "\033[32m *************************************** \033[0m"

    $Command01  2>>${TempFFMPEGImageLog}
    [ $? -ne 0 ] && return 1

    $Command02 2>>${TempFFMPEGImageLog}
    [ $? -ne 0 ] && return 1

    runUpdateImageInfo
}

runCapturePictureFromMP4()
{
    let "PicIdx = 0"
    for((i=0; i< ${PicNum}; i++))
    do
        TimeStamp=`echo  "scale=2; ${FrameInterval} * $i " | bc`
        IntNum=`echo ${TimeStamp} | awk 'BEGIN {FS="."} {print $1}'`
        [ "${IntNum}" = "" ] && TimeStamp="0${TimeStamp}"

        runParseOneComparisonPictureFromMP4
        [ $? -ne 0 ] && return 1

        let "PicIdx   += 1"
        let "ImageIdx += 1"
    done
}

runParseAllComparisonMp4File()
{
    while read line
    do
        OriginFile=`echo ${line} | awk '{print $2}'`
        MP4File01=`ls ${InputMp4Dir}/*.mp4 | grep ${OriginFile} |  grep ${Pattern1} | head -n 1`

        [ -z "$MP4File01" ] && echo "no match file for comparison" && continue
        MP4File02=`ls ${InputMp4Dir}/*.mp4 | grep ${OriginFile} |  grep ${Pattern2} | head -n 1`
        [ -z "$MP4File02" ] && echo "no match file for comparison" && continue

        echo -e "\033[34m ********************************* \033[0m"
        echo -e "\033[34m MP4Idx    is: ${MP4Idx}           \033[0m"
        echo -e "\033[34m MP4File01 is: ${MP4File01}        \033[0m"
        echo -e "\033[34m MP4File02 is: ${MP4File02}        \033[0m"
        echo -e "\033[34m ********************************* \033[0m"

        runPareseTimeStampInfo
        runCapturePictureFromMP4
        [ $? -ne 0 ] && echo  "OriginFile $OriginFile failed " && continue

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

