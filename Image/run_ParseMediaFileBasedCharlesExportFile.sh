#!/bin/bash
#********************************************************************************
#
#********************************************************************************

runUsage()
{
    echo -e "\033[31m ******************************************* \033[0m"
    echo "   Usage:                                                "
    echo "      $0  \$CharlesExportFile \${OutputDir}              "
    echo "      --CharlesExportFile:  csv file export from charles "
    echo "      --OutputDir: output dir  "
    echo -e "\033[31m ******************************************* \033[0m"
}

runInint()
{
    Date=`date +%y%m%d%H%S`
    CurrentDir=`pwd`
    DefaultOutputDir="${CurrentDir}/OutputMedia"
    URL=""
    MediaOutputDir=""
    MediaFileName=""
    MediaListInfo=""
    MediaType=""
    MediaFormat=""
    let "FileOutputIndex = 0"
    AllMediaFileList="AllMediaFileList-${Date}.csv"

    HeadLine="Index,FileName,Type,Format,PicW,PicH,Size,CR,URL"
    AllMediaHeadLine="Domain,Index,FileName,Type,Format,PicW,PicH,Size,CR,Outputdir,URL"
}

runDomainMapping()
{
    Maping=("" \
            "" )


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

runUpdateMediaInfo()
{
    [ -e ${MediaListInfo} ]    || echo ${HeadLine} >${MediaListInfo}
    [ -e ${AllMediaFileList} ] || echo ${AllMediaHeadLine} >${AllMediaFileList}

    #update media file info
    MediaInfo="${FileOutputIndex},${MediaFileName},${MediaType},${MediaFormat}"
    MediaInfo="${MediaInfo},${PicW},${PicH},${MediaFileSizeInkB},${CompressionRate},${URL}"

    MediaInfoForAll="${Domain},${FileOutputIndex},${MediaFileName},${MediaType}"
    MediaInfoForAll="${MediaInfoForAll},${MediaFormat},${PicW},${PicH},${MediaFileSizeInkB}"
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
        [ "$MediaFormat" != "png" ] && continue

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

    [ -z "${OutputDir}" ] && OutputDir="${DefaultOutputDir}"
    mkdir -p ${OutputDir}

    cd ${OutputDir} && OutputDir=`pwd` && cd -
}

runMain()
{
    runInint
    runCheck

    runParseAllMdediaFile
}

#*****************************************************

if [ $# -lt 1 ]
then
    runUsage
    exit 1
fi

CharlesExportFile=$1
OutputDir=$2

runMain
#*****************************************************
