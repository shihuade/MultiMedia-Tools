#!/bin/bash
#*********************************************************************
#  brief:
#       for x265 enc params deep learning
#       both single and combination enc parametes
#*********************************************************************

runUsage()
{
    echo -e "\033[31m ***************************************** \033[0m"
    echo "  Usage:                                                   "
    echo "      $0  \$Input  \$option                                "
    echo "                                                           "
    echo "      $0  \$InputYUV:    YUV for x264 encoding             "
    echo "                                                           "
    echo "      $0  \$InputYUVDir  for all YUVs testing              "
    echo "                                                           "
    echo "      $0  \$InputYUVDir  \"TestSet01\" for TestSet01 YUVs  "
    echo "                                                           "
    echo -e "\033[31m ***************************************** \033[0m"
}

runInit()
{
    CurDir=`pwd`
    FileNamePattern="x265"
    MP4ParserScript="../MP4Info/run_ParseMP4Info.sh"
    YUVInfoScript="./run_ParseYUVInfo.sh"
    x264EncParserScript="./run_PareseX264EncLog.sh"
    x264EncLog=""
    x264EncPerfInfo=""

    ReportDir="${CurDir}/Report_x265"
    BitStreamDir="${CurDir}/BitStream_x265"
    mkdir -p ${ReportDir}
    mkdir -p ${BitStreamDir}

    AllMP4Info="${ReportDir}/Report_${FileNamePattern}_AllMP4Info_${EncParamName}.csv"
    AllMP4InfoParserConsole="${ReportDir}/Report_${FileNamePattern}_AllMP4InfoDetail_${EncParamName}.txt"

    x264EncReport="${ReportDir}/Report_${FileNamePattern}_Summary_${EncParamName}.csv"

    HeadLine="YUVFile, ParaName, ParamVal, CR, YUVSize(KBs), BitStreamSize(kBs)"
    HeadLine="${HeadLine},BitRate, PSNRY, PSNRU,  PSNRV, FPS, Time(s), SHA1-Org, SHA1-Trans"

    echo "${HeadLine}">${x264EncReport}
}

runUpdatex264EncStatic()
{
    #parse origin and transcoded mp4 files' info
    YUVName=`basename $InputYUV`

    YUVSize=`ls -l ${InputYUV} | awk '{print $5}'`
    BitstreamSize=`ls -l ${OutputBitStream} | awk '{print $5}'`

    YUVSize=`echo  "scale=2; ${YUVSize} / 1024" | bc`
    BitstreamSize=`echo  "scale=2; ${BitstreamSize} /1024"   | bc`

    CompressRate=`echo  "scale=2; ${YUVSize} / ${BitstreamSize}" | bc`
    EncodeTime=`echo  "scale=2; ${EndTime} - ${StartTime}" | bc`

    SHA1Org=`openssl sha1 $InputYUV       | awk '{print $2}'`
    SHA1Trans=`openssl sha1 $OutputBitStream  | awk '{print $2}'`

    #BitRate, PSNRY, PSNRU,  PSNRV, FPS
    x264EncPerfInfo=`${x264EncParserScript} ${x264EncLog}`

    x264EncStatic="${YUVName}, ${EncParamName}, ${EncParam}, ${CompressRate}, ${YUVSize}, ${BitstreamSize}"
    x264EncStatic="${x264EncStatic}, ${x264EncPerfInfo}, ${EncodeTime}, ${SHA1Org}, ${SHA1Trans}"

    echo "${x264EncStatic}" >>${x264EncReport}
}

runx264EncParam()
{
    YUVInfo=(`${YUVInfoScript} $InputYUV`)
    PicW=${YUVInfo[0]}
    PicH=${YUVInfo[1]}
    FPS=${YUVInfo[2]}
    [ -z "$FPS" ] && FPS="30"

    ParamNum=${#aEncParam[@]}
    for((i=0; i<$ParamNum; i++))
    do
        EncParam="${aEncParam[$i]}"
        EncParamString=`echo ${EncParam} | awk '{for(i=1; i<=NF; i++) printf("%s_", $i) }'`
        YUVName=`basename $InputYUV`
        OutputBitStream="${BitStreamDir}/${YUVName}_${FileNamePattern}_${EncParamName}_${EncParamString}.264"
        OutputMp4="${BitStreamDir}/${YUVName}_${FileNamePattern}_${EncParamName}_${EncParamString}.264.mp4"
        x264EncLog="${BitStreamDir}/${YUVName}_${FileNamePattern}_${EncParamName}_${EncParamString}_enc.txt"
        EncCommand="x265 --input ${InputYUV} --fps ${FPS} --input-res ${PicW}x${PicH} --output  ${OutputBitStream} "
        EncCommand="${EncCommand} ${EncParamArg} ${EncParam}  --psnr  ${EncParamPlus} "
        MP4Command="ffmpeg -framerate ${FPS} -i ${OutputBitStream} -c copy -y ${OutputMp4}"

        echo -e "\033[32m ***************************************** \033[0m"
        echo "  EncParam        is ${EncParamArg} ${EncParam}"
        echo "  InputYUV        is ${InputYUV}"
        echo "  OutputBitStream is ${OutputBitStream}"
        echo "  x264EncLog      is ${x264EncLog}"
        echo "  OutputMp4       is ${OutputMp4}"
        echo "  EncCommand      is ${EncCommand}"
        echo "  MP4Command      is ${MP4Command}"
        echo -e "\033[32m ***************************************** \033[0m"

        #start
        StartTime=`date +%s`
        echo "${EncCommand}" >${x264EncLog}
        ${EncCommand}      2>>${x264EncLog}
        EndTime=`date +%s`

        #generate mp4 file based on bitstream
        ${MP4Command}

        #update x264 enc performance data
        runUpdatex264EncStatic
    done
}

runGetAllMP4StaticInfo()
{
    Command="${MP4ParserScript} ${BitStreamDir} ${AllMP4Info} ${Pattern}"
    echo "Parse command is $Command"
    ${Command}
}

runPrompt()
{
    echo -e "\033[32m ************************************************************ \033[0m"
    echo "     x264EncReport:       ${x264EncReport}                                      "
    echo "                                                                                "
    echo "     All mp4 static info: ${AllMP4Info}                                         "
    echo "                                                                                "
    echo -e "\033[32m ************************************************************ \033[0m"
}

runCheck()
{
    [ -f "$Input" ] || [ -d "$Input" ] || Flag="False"

    if [ "$Flag" = "False" ]
    then
        echo "Input yuv file or dir doest not exist, please double check!"
        runUsage
        exit 1
    fi

    [ -d "$Input" ] && InputYUVDir=$Input
    [ -f "$Input" ] && InputYUV=$Input && InputYUVDir=`dirname $Input`

    ls -l ${InputYUVDir}/*${Pattern}*.yuv
    if [ $? -ne 0 ];then
        echo -e "\033[31m ******************************************************* \033[0m"
        echo -e "\033[31m     No YUV files' name matched with Pattern ${Pattern}! \033[0m"
        echo -e "\033[31m ******************************************************* \033[0m"

        exit 1
    fi
}



runx264EncDeblocking()
{
    EncParamName="Deblock_CRF23"
    EncParamPlus="--profile main --level 31 --crf 23"
    EncParamArg="--deblock "

    aDeblocingParams=(-6 -3  -1 0 1 2 3 6)
    let "i=0"
    for Deblock in ${aDeblocingParams[@]}
    do
        aEncParam[$i]=" ${Deblock}:${Deblock} "
        let "i ++"
    done
    #aEncParam=(2 3 4 5)
}


runInitForTestParams()
{
    runx264EncDeblocking
    runInit
}

runTestAllYUVs()
{
    for YUVFile in ${InputYUVDir}/*${Pattern}*.yuv
    do
        InputYUV="$YUVFile"
        runx264EncParam
    done
}

runMain()
{
    runCheck
    runInitForTestParams

    [ -d "${Input}" ] && runTestAllYUVs
    [ -f "${Input}" ] && InputYUV="$Input" && runx264EncParam

    #get all mp4 info for which based encoded bitstream
    runGetAllMP4StaticInfo  >${AllMP4InfoParserConsole}

    runPrompt
}

#*****************************************************

if [ $# -lt 1 ]
then
    runUsage
    exit 1
fi

Input=$1
Pattern=$2

runMain
#*****************************************************

