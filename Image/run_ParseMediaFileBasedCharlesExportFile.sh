#!/bin/bash
#********************************************************************************
#
#********************************************************************************

runUsage()
{
    echo -e "\033[31m ******************************************* \033[0m"
    echo "   Usage:                                                "
    echo "      $0  \$CharlesExportFile \${AppName}                "
    echo "      --CharlesExportFile:  csv file export from charles "
    echo "      --AppName: like Douyin Kuaishou TuDou MiaoPai      "
    echo -e "\033[31m ******************************************* \033[0m"
}

runInint()
{
    Date=`date +%y%m%d%H%S`
    CurrentDir=`pwd`
    DefaultOutputDir="${CurrentDir}/MediaOutput"
    LabelCfgDir="${CurrentDir}/LabelCfg"
    LabelCfgList="${LabelCfgDir}/Label-list.txt"
    URL=""
    MediaOutputDir=""
    MediaFileName=""
    MediaListInfo=""
    MediaType=""
    MediaFormat=""
    let "FileOutputIndex = 0"

    HeadLine="Index,FileName,Type,Format,AppLabel,SubLabel,SizeLabel,PicW,PicH,Size,CR,URL"
    AllMediaHeadLine="Domain,Index,FileName,Type,Format,AppLabel,SubLabel,SizeLabel,\
    PicW,PicH,Size,CR,Outputdir,URL"


    SubDirName=`basename ${CharlesExportFile} | awk 'BEGIN {FS=".csv"} {print $1}'`
    OutputDir="${DefaultOutputDir}/${SubDirName}"
    mkdir -p ${OutputDir}
    cd ${OutputDir} && OutputDir=`pwd` && cd -

    AllMediaFileList="${OutputDir}/${AppName}-${Date}.csv"

    # for resolution label
    let "FrameSize_90p   = 160  * 90  "
    let "FrameSize_180p  = 320  * 180 "
    let "FrameSize_360p  = 640  * 360 "
    let "FrameSize_540p  = 540  * 960 "
    let "FrameSize_720p  = 1280 * 720 "
    let "FrameSize_1080p = 1920 * 1080"
}

runGetLabelCfgFile()
{
    LabelFile=`cat ${LabelCfgList} | grep -i ${AppName}`

    if [ "${LabelFile}X" = "X" ]; then
        echo -e "\033[31m *********************************************** \033[0m"
        echo -e "\033[31m  No mapping cfg file for ${AppName}             \033[0m"
        echo -e "\033[31m  Please check and manual update the mapping cfg \033[0m"
        echo -e "\033[31m  Mapping file format is:                       \033[0m"
        echo -e "\033[31m         \${AppName}-Mapping.csv                \033[0m"
        echo -e "\033[31m *********************************************** \033[0m"
        echo -e "\033[33m current mapping cfg files list are:             \033[0m"
        cat ${LabelCfgList}
        echo -e "\033[33m *********************************************** \033[0m"

        exit 1
    fi

    LabelMappingFile="${LabelCfgDir}/${LabelFile}"
}

runParseURLInfo()
{
    URL=`echo $URLInfo | awk 'BEGIN {FS=","} {print $1}'`
    Domain=`echo $URL  | awk 'BEGIN {FS="/"} {print $3}'`

    #image/webp, image/jpeg, video/mp4, etc.
    ContentType=`echo $URLInfo     | awk 'BEGIN {FS=","} {print $6}'`
    MediaType=`echo $ContentType   | awk 'BEGIN {FS="/"} {print $1}'`
    MediaFormat=`echo $ContentType | awk 'BEGIN {FS="/"} {print $2}'`

    #echo -e "\033[32m ****************************************** \033[0m"
    #echo -e "\033[32m MediaType       is: ${MediaType}           \033[0m"
    #echo -e "\033[32m MediaFormat     is: ${MediaFormat}         \033[0m"
    #echo -e "\033[32m Domain          is: ${Domain}              \033[0m"
    #echo -e "\033[32m URL             is: ${URL}                 \033[0m"
    #echo -e "\033[32m ****************************************** \033[0m"
}

runGenrateUpdateFile()
{
    #output dir
    MediaOutputDir="${OutputDir}/${Domain}/${MediaFormat}"
    [ -d ${MediaOutputDir} ] || mkdir -p ${MediaOutputDir}

    #record and update file index based on log file
    FileIndexLog="${MediaOutputDir}/${Domain}-${Date}-index.txt"
    if [ ! -e ${FileIndexLog} ]; then
        let "FileOutputIndex = 0"
    else
        FileOutputIndex=`cat ${FileIndexLog}`
        let "FileOutputIndex += 1"
    fi
    echo "${FileOutputIndex}" > ${FileIndexLog}

    #generate media ouput dir and file name
    MediaFileName="${Domain}-${Date}-${FileOutputIndex}.${MediaFormat}"
    MediaFile="${MediaOutputDir}/${MediaFileName}"
    MediaListInfo="${MediaOutputDir}/${Domain}-${Date}-${MediaType}.csv"
}

runDownloadMediaFile()
{
  wget ${URL} -o wget-download-log.txt -O "${MediaOutputDir}/${MediaFileName}"
    if [ ! -e ${MediaFile} ]; then
        echo "${MediaFile} download failed!"
        echo "--URL is ${URL}"
        return 1
    fi

    MediaFileSizeInkB=`ls -l ${MediaFile} | awk '{print $5}'`

    #skip those size less than 1kB
    if [ ${MediaFileSizeInkB} -lt 1024 ]; then
        rm -f ${MediaFile}
        return 1
    fi

    MediaFileSizeInkB=`echo  "scale=2; ${MediaFileSizeInkB} / 1024" | bc`
}

runDoubleCheckMediaFile()
{
    if [ "$MediaFormat" = "webp" ]; then
        IsWebP=`file ${MediaFile} | grep "VP8 encoding"`

        if [ "${IsWebP}X" = "X" ]; then
            MediaFormat="jpeg"
            mv ${MediaFile} ${MediaFile}.jpeg
            MediaFile="${MediaFile}.jpeg"
        fi
    fi

    if [ "$MediaFormat" = "png" ]; then
        IsPng=`file ${MediaFile} | grep "PNG image data"`

        if [ "${IsPng}X" = "X" ]; then
            MediaFormat="jpeg"
            mv ${MediaFile} ${MediaFile}.jpeg
            MediaFile="${MediaFile}.jpeg"
        fi
    fi
}

runParseMediaFileInfo()
{
    let "PicW = 0"
    let "PicH = 0"
    let "CompressionRate = 0"

    if [ "$MediaFormat" = "jpeg" ]; then
        ResolutionInfo=`file ${MediaFile}      | awk 'BEGIN {FS="precision"} {print $NF}'`
        ResolutionInfo=`echo ${ResolutionInfo} | awk 'BEGIN {FS=","} {print $2}'`
    elif [ "$MediaFormat" = "jpg" ]; then
        ResolutionInfo=`file ${MediaFile}      | awk 'BEGIN {FS="precision"} {print $NF}'`
        ResolutionInfo=`echo ${ResolutionInfo} | awk 'BEGIN {FS=","} {print $2}'`
    elif [ "$MediaFormat" = "png" ]; then
        ResolutionInfo=`file ${MediaFile} | awk 'BEGIN {FS="PNG image data"} {print $NF}'`
        ResolutionInfo=`echo ${ResolutionInfo} | awk 'BEGIN {FS=","} {print $2}'`
    elif [ "$MediaFormat" = "gif" ]; then
        ResolutionInfo=`file ${MediaFile}      | awk 'BEGIN {FS="GIF image data"} {print $NF}'`
        ResolutionInfo=`echo ${ResolutionInfo} | awk 'BEGIN {FS=","} {print $3}'`
    elif [ "$MediaFormat" = "webp" ]; then
        ResolutionInfo=`file ${MediaFile}      | awk 'BEGIN {FS="VP8 encoding"} {print $NF}'`
        ResolutionInfo=`echo ${ResolutionInfo} | awk 'BEGIN {FS=","} {print $2}'`
    else
        ResolutionInfo="0x0"
    fi

    #echo "MediaFile is $MediaFile"
    #file ${MediaFile}
    #echo "ResolutionInfo is $ResolutionInfo"

    PicW=`echo ${ResolutionInfo} | awk 'BEGIN {FS="[xX]"} {print $1}'`
    PicH=`echo ${ResolutionInfo} | awk 'BEGIN {FS="[xX]"} {print $2}'`
    let "PicW = ${PicW}"
    let "PicH = ${PicH}"

    [ ${PicW} -eq 0 ] || [ ${PicH} -eq 0 ] && return 1

    FrameSizeInkB=`echo  "scale=2; ${PicW} * ${PicH} * 12 / 8 / 1024" | bc`
    CompressionRate=`echo  "scale=2; ${FrameSizeInkB} / ${MediaFileSizeInkB}" | bc`
}

runRenameMediaFile()
{
    Prefix_01=""
    Prefix_02="${PicW}x${PicH}_${MediaFileSizeInkB}kBs_CR${CompressionRate}"

    Suffix="${MediaFormat}"

    if [ "$MediaFormat" = "jpeg" ]; then
        Prefix_01=`echo ${MediaFileName}  | awk 'BEGIN {FS=".jpeg"} {print $1}'`
    elif [ "$MediaFormat" = "png" ]; then
    Prefix_01=`echo ${MediaFileName}  | awk 'BEGIN {FS=".png"} {print $1}'`

    elif [ "$MediaFormat" = "gif" ]; then
        Prefix_01=`echo ${MediaFileName}  | awk 'BEGIN {FS=".gif"} {print $1}'`
    elif [ "$MediaFormat" = "webp" ]; then
        Prefix_01=`echo ${MediaFileName}  | awk 'BEGIN {FS=".webp"} {print $1}'`
    else
        Prefix_01="${MediaFileName}"
    fi

    MediaFileName="${Prefix_01}_${Prefix_02}.${Suffix}"
    NewMediaFile="${MediaOutputDir}/${MediaFileName}"

    mv ${MediaFile} ${NewMediaFile}
    MediaFile=${NewMediaFile}
}

runParseLabel()
{
    #wa.gtimg.com,	image,	jpeg,	1080,	1920,	Tencent-News,	Add,
    AppLabel=`echo ${LabelCategory}   | awk 'BEGIN {FS=","} {print $6}'`
    SubLabel=`echo ${LabelCategory}   | awk 'BEGIN {FS=","} {print $7}'`
    LabelPicW=`echo ${LabelCategory}  | awk 'BEGIN {FS=","} {print $4}'`
    LabelPicH=`echo ${LabelCategory}  | awk 'BEGIN {FS=","} {print $5}'`
}

runGetBestLabel()
{
    #************************************
    #return 0: match, 1: not match
    #************************************
    #case1:   720x720 ==>Avatar
    #  300   300  Small
    #  1080  1080 Avatar
    #case2: 480x640 ==>Cover
    #  100   100  Small
    #  1080  1080 Avatar
    #  540   960  Cover
    #case3: 480x640 ==>Unkown
    #  100   100  Small
    #  1080  1080 Avatar
    #case3: 480x480 ==>Unkown
    #  540   960  Small
    #  1280  128  Ad
    #************************************

    if [ ${PicW} -eq ${PicH} ] && [ ${LabelPicW} -eq ${LabelPicH} ];then
        [ ${PicW} -le 300 ] && [ ${LabelPicW} -le 300 ] && return 0
        [ ${PicW} -gt 300 ] && [ ${LabelPicW} -gt 300 ] && return 0

    elif [ ${PicW} -eq ${PicH} ] && [ ${LabelPicW} -ne ${LabelPicH} ];then
        return 1
    elif [ ${PicW} -ne ${PicH} ] && [ ${LabelPicW} -eq ${LabelPicH} ];then
        return 1
    elif [ ${PicW} -ne ${PicH} ] && [ ${LabelPicW} -ne ${LabelPicH} ];then
        return 0
    fi
}

runGenerateResulotionLabel()
{
    let "LabelFrameSize = ${PicW} * ${PicH}"

    [ ${LabelFrameSize} -ge ${FrameSize_1080p} ] && SizeLabel="1080p" && return 0
    [ ${LabelFrameSize} -ge ${FrameSize_720p}  ] && SizeLabel="720p"  && return 0
    [ ${LabelFrameSize} -ge ${FrameSize_540p}  ] && SizeLabel="540p"  && return 0
    [ ${LabelFrameSize} -ge ${FrameSize_360p}  ] && SizeLabel="360p"  && return 0
    [ ${LabelFrameSize} -ge ${FrameSize_180p}  ] && SizeLabel="180p"  && return 0

    SizeLabel="90p"
    return 0
}

runGenerateMediaLabel()
{
    MatchLabelLog="MatchLabelList.txt"

    cat ${LabelMappingFile} | grep "${Domain}" |grep "${MediaFormat}" >${MatchLabelLog}
    NumLabel=`wc -l ${MatchLabelLog} | awk '{print $1}'`
    if [ ${NumLabel} -eq 1 ]; then
        LabelCategory=`cat ${MatchLabelLog}`
        runParseLabel
        return 0
    fi

    let "Flag = 0"
    while read line
    do
        LabelCategory=${line}

        runParseLabel
        runGetBestLabel
        [ $? -eq 0 ] && let "Flag = 1" && break
    done <${MatchLabelLog}

   [ ${Flag} -eq 0 ] && SubLabel="Unkown"
}

runUpdateMediaInfo()
{
    [ -e ${MediaListInfo} ]    || echo ${HeadLine} >${MediaListInfo}
    [ -e ${AllMediaFileList} ] || echo ${AllMediaHeadLine} >${AllMediaFileList}

    #update media file info
    MediaInfo="${FileOutputIndex},${MediaFileName},${MediaType},${MediaFormat},${AppLabel},${SubLabel},${SizeLabel}"
    MediaInfo="${MediaInfo},${PicW},${PicH},${MediaFileSizeInkB},${CompressionRate},${URL}"

    MediaInfoForAll="${Domain},${FileOutputIndex},${MediaFileName},${MediaType}"
    MediaInfoForAll="${MediaInfoForAll},${MediaFormat},${AppLabel},${SubLabel},${SizeLabel},${PicW},${PicH},${MediaFileSizeInkB}"
    MediaInfoForAll="${MediaInfoForAll},${CompressionRate},${MediaOutputDir},${URL}"
    echo "${MediaInfo}"       >>${MediaListInfo}
    echo "${MediaInfoForAll}" >>${AllMediaFileList}
}

runOutputMediaInfo()
{
    echo -e "\033[32m ****************************************** \033[0m"
    echo -e "\033[32m MediaType       is: ${MediaType}           \033[0m"
    echo -e "\033[32m MediaFormat     is: ${MediaFormat}         \033[0m"
    echo -e "\033[32m Domain          is: ${Domain}              \033[0m"
    echo -e "\033[32m MediaOutputDir  is: ${MediaOutputDir}      \033[0m"
    echo -e "\033[32m MediaFileName   is: ${MediaFileName}       \033[0m"
    echo -e "\033[32m URL             is: ${URL}                 \033[0m"
    echo -e "\033[32m File index      is: ${FileOutputIndex}     \033[0m"
    echo -e "\033[32m MediaInfo       is: ${PicW} x ${PicH}      \033[0m"
    echo -e "\033[32m FrameSizeInkB   is: ${FrameSizeInkB}       \033[0m"
    echo -e "\033[32m CompressionRate is: ${CompressionRate}     \033[0m"
    echo -e "\033[32m AppLabel        is: ${AppLabel}            \033[0m"
    echo -e "\033[32m SubLabel        is: ${SubLabel}            \033[0m"
    echo -e "\033[32m ****************************************** \033[0m"
}

runParseAllMdediaFile()
{
    PreviousURL=""
    while read line
    do
        URLInfo="$line"
        runParseURLInfo
        [ "${PreviousURL}" = "${URL}" ] &&  continue

        #[ "$MediaType"   != "image" ] && [ "$MediaType"   != "mp4" ] && continue
        [ "$MediaType"   != "image" ] && continue

#[ "$MediaFormat" != "png" ] && continue
#[ "$MediaType"   != "mp4" ] && continue
        #[ "$MediaFormat" != "jpeg"  ] && continue

        runGenrateUpdateFile

        #download media file
        runDownloadMediaFile
        [ $? -ne 0 ] && continue

        runDoubleCheckMediaFile

        #parse media file info
        runParseMediaFileInfo
        runRenameMediaFile

        #add label
        #if no label mapping cfg file, please comment out below funtion
        # and mapping file checking function
        runGenerateMediaLabel
#add resolution label
runGenerateResulotionLabel

        runUpdateMediaInfo
        runOutputMediaInfo

        PreviousURL="$URL"
    done < ${CharlesExportFile}
}

runCheck()
{

    if [ ! -e ${CharlesExportFile} ]
    then
        echo "charles export file does not exist, please double check"
        runUsage
        exit 1
    fi
}

runMain()
{
    runCheck

    runInint
    runGetLabelCfgFile

runParseAllMdediaFile
}

#*****************************************************

if [ $# -lt 2 ]
then
    runUsage
    exit 1
fi

CharlesExportFile=$1
AppName=$2

runMain
#*****************************************************
