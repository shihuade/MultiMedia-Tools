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
    echo "      $0  \$InputYUV:    YUV for x265 encoding             "
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
    Pattern="x265"
    MP4ParserScript="../MP4Info/run_ParseMP4Info.sh"
    YUVInfoScript="./run_ParseYUVInfo.sh"
    x265EncParserScript="./run_ParseX265Log.sh"
    x265EncLog=""
    x265EncPerfInfo=""

    ReportDir="${CurDir}/Report_x265"
    BitStreamDir="${CurDir}/BitStream_x265"
    mkdir -p ${ReportDir}
    mkdir -p ${BitStreamDir}

    AllMP4Info="${ReportDir}/Report_${Pattern}_AllMP4Info_${TestName}.csv"
    MP4InfoConsole="${ReportDir}/Report_${Pattern}_AllMP4Info_${TestName}.txt"
    x265EncReport="${ReportDir}/Report_${Pattern}_Summary_${TestName}.csv"

    HeadLine="YUVFile, ParaName, ParamVal, CR, YUVSize(KBs), StreamSize(kBs)"
    HeadLine="${HeadLine},BitRate(kbps), GlobalPSNR, FPS, Time(s), SHA1-Org, SHA1-Trans"

    echo "${HeadLine}">${x265EncReport}
}

runUpdatex265EncStatic()
{
    #parse origin and transcoded mp4 files' info
    YUVName=`basename $InputYUV`

    YUVSize=`ls -l ${InputYUV} | awk '{print $5}'`
    StreamSize=`ls -l ${X265Stream} | awk '{print $5}'`
    YUVSize=`echo "scale=2; ${YUVSize} / 1024" | bc`
    StreamSize=`echo "scale=2; ${StreamSize} /1024"   | bc`

    CompressedRate=`echo "scale=2; ${YUVSize} / ${StreamSize}" | bc`
    EncodeTime=`echo "scale=2; ${EndTime} - ${StartTime}" | bc`

    SHA1Org=`openssl sha1 $InputYUV       | awk '{print $2}'`
    SHA1Trans=`openssl sha1 $X265Stream  | awk '{print $2}'`

    #BitRate, PSNRY, PSNRU,  PSNRV, FPS
    x265EncPerfInfo=`${x265EncParserScript} ${x265EncLog}`

    x265EncStatic="${YUVName}, ${TestName}, ${ParamVal}, ${CompressedRate}, ${YUVSize}, ${StreamSize}"
    x265EncStatic="${x265EncStatic}, ${x265EncPerfInfo}, ${EncodeTime}, ${SHA1Org}, ${SHA1Trans}"

    echo "${x265EncStatic}" >>${x265EncReport}
}

runx265WithParamVal()
{
    YUVName=`basename $InputYUV`
    YUVInfo=(`${YUVInfoScript} $InputYUV`)
    PicW=${YUVInfo[0]}
    PicH=${YUVInfo[1]}
    FPS=${YUVInfo[2]}
    [ -z "$FPS" ] && FPS="30"

    ParamNum=${#aParamVal[@]}
    for((i=0; i<$ParamNum; i++))
    do
        ParamVal="${aParamVal[$i]}"
        ParamString=`echo ${ParamVal} | awk '{for(i=1; i<=NF; i++) printf("%s_", $i) }'`
        x265EncLog="${BitStreamDir}/${YUVName}_${Pattern}_${TestName}_${ParamString}_enc.txt"
        X265Stream="${BitStreamDir}/${YUVName}_${Pattern}_${TestName}_${ParamString}.265"
        OutputMp4="${BitStreamDir}/${YUVName}_${Pattern}_${TestName}_${ParamString}.265.mp4"

        EncCommand="x265 --psnr --input ${InputYUV} --fps ${FPS} --input-res ${PicW}x${PicH} --output  ${X265Stream} "
        EncCommand="${EncCommand} ${ParamName} ${ParamVal} ${ParamPlus} "
        MP4Command="ffmpeg -framerate ${FPS}  -setpts=PTS-STARTPTS -i ${X265Stream} -c copy -y ${OutputMp4}"

        echo -e "\033[32m ***************************************** \033[0m"
        echo "  InputYUV        is ${InputYUV}"
        echo "  ParamVal        is ${ParamName} ${ParamVal}"
        echo "  X265Stream      is ${X265Stream}"
        echo "  x265EncLog      is ${x265EncLog}"
        echo "  OutputMp4       is ${OutputMp4}"
        echo "  EncCommand      is ${EncCommand}"
        echo "  MP4Command      is ${MP4Command}"
        echo -e "\033[32m ***************************************** \033[0m"

        #start
        StartTime=`date +%s`
        echo "${EncCommand}" >${x265EncLog}
        ${EncCommand}      2>>${x265EncLog}
        EndTime=`date +%s`

        #generate mp4 file based on bitstream
        ${MP4Command} 2>MP4Gen.txt

        #update x265 enc performance data
        runUpdatex265EncStatic
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
    echo "     x265EncReport:       ${x265EncReport}                                      "
    echo "                                                                                "
    echo "     All mp4 static info: ${AllMP4Info}                                         "
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

runx265EncDeblocking()
{
    TestName="Deblock_CRF23"
    ParamPlus="--profile main --level 31 --crf 23"
    ParamName="--deblock "

    aDeblocingParams=(0 1)
    let "i=0"
    for Deblock in ${aDeblocingParams[@]}
    do
        aParamVal[$i]=" ${Deblock}:${Deblock} "
        let "i ++"
    done
    #aParamVal=(2 3 4 5)
}


runInitForTestParams()
{
    runx265EncDeblocking
    runInit
}

runTestAllYUVs()
{
    for YUVFile in ${InputYUVDir}/*${Pattern}*.yuv
    do
        InputYUV="$YUVFile"
        runx265WithParamVal
    done
}

runMain()
{
    runCheck
    runInitForTestParams

    [ -d "${Input}" ] && runTestAllYUVs
    [ -f "${Input}" ] && InputYUV="$Input" && runx265WithParamVal

    #get all mp4 info for which based encoded bitstream
    runGetAllMP4StaticInfo  >${MP4InfoConsole}

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

