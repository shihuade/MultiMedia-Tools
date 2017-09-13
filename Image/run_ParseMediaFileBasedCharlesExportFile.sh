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
    Date=`date +%y%m%d-%H-%S`
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

    HeadLine="Index, FileName, Type, Format, URL"
    AllMediaHeadLine="Domain, Index, FileName, Type, Format, Outputdir, URL"
}

runParseURLInfo()
{
    URL=`echo $URLInfo | awk 'BEGIN {FS=","} {print $1}'`
    Domain=`echo $URL  | awk 'BEGIN {FS="/"} {print $3}'`

    #image/webp, image/jpeg, video/mp4, etc.
    ContentType=`echo $URLInfo     | awk 'BEGIN {FS=","} {print $6}'`
    MediaType=`echo $ContentType   | awk 'BEGIN {FS="/"} {print $1}'`
    MediaFormat=`echo $ContentType | awk 'BEGIN {FS="/"} {print $2}'`
}

runOutputMediaInfo()
{
    echo -e "\033[32m ***************************************** \033[0m"
    echo -e "\033[32m MediaType      is: ${MediaType}           \033[0m"
    echo -e "\033[32m MediaFormat    is: ${MediaFormat}         \033[0m"
    echo -e "\033[32m Domain         is: ${Domain}              \033[0m"
    echo -e "\033[32m MediaOutputDir is: ${MediaOutputDir}      \033[0m"
    echo -e "\033[32m MediaFileName  is: ${MediaFileName}       \033[0m"
    echo -e "\033[32m URL            is: ${URL}                 \033[0m"
    echo -e "\033[32m File index     is: ${FileOutputIndex}     \033[0m"
    echo -e "\033[32m ***************************************** \033[0m"
}

runParseMediaContent()
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
    MediaListInfo="${MediaOutputDir}/${Domain}-${Date}-${MediaType}.csv"
    [ -e ${MediaListInfo} ]    || echo ${HeadLine} >${MediaListInfo}
    [ -e ${AllMediaFileList} ] || echo ${AllMediaHeadLine} >${AllMediaFileList}

    #update media file info
    MediaInfo="${FileOutputIndex}, ${MediaFileName}, ${MediaType}, ${MediaFormat}, ${URL}"
    MediaInfoForAll="${Domain}, ${FileOutputIndex}, ${MediaFileName}, ${MediaType}, ${MediaFormat}, ${MediaOutputDir}, ${URL}"
    echo "${MediaInfo}"       >>${MediaListInfo}
    echo "${MediaInfoForAll}" >>${AllMediaFileList}
}

runDownloadMediaFile()
{
echo ""

}

runParseAllMdediaFile()
{
    PreviousURL=""
    while read line
    do
        URLInfo="$line"
        runParseURLInfo
        [ "${PreviousURL}" = "${URL}" ] &&  continue

        [ "$MediaType" = "image" ] || [ "$MediaType" = "video" ] || continue

        runParseMediaContent
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
