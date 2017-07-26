#!/bin/bash
#*********************************************************************
#  brief:
#       for x264 enc params deep learning
#       both single and combination enc parametes
#
#*********************************************************************

runUsage()
{
    echo -e "\033[31m ***************************************** \033[0m"
    echo " Usage:                                                    "
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
    FileNamePattern="x264Enc"
    MP4ParserScript="../MP4Info/run_ParseMP4Info.sh"
    x264EncParserScript="./run_PareseX264EncLog.sh"
    x264EncLog=""
    x264EncPerfInfo=""

    AllMP4Info="${InputYUVDir}/Report_${FileNamePattern}_AllMP4Info_${EncParamName}.csv"
    AllMP4InfoParserConsole="${InputYUVDir}/Report_${FileNamePattern}_AllMP4InfoDetail_${EncParamName}.txt"

    x264EncReport="${InputYUVDir}/Report_${FileNamePattern}_Summary_${EncParamName}.csv"

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
    FPS=`echo $InputYUV | awk 'BEGIN {FS="fps"} {print $1}' | awk 'BEGIN {FS="_"} {print $NF}'`
    [ -z "$FPS" ] && FPS="30"
    for EncParam in ${aEncParam[@]}
    do
        OutputBitStream="${InputYUV}_${FileNamePattern}_${EncParamName}_${EncParam}.264"
        OutputMp4="${InputYUV}_${FileNamePattern}_${EncParamName}_${EncParam}.264.mp4"
        x264EncLog="${InputYUV}_${FileNamePattern}_${EncParamName}_${EncParam}_enc.txt"
        EncCommand="x264 --psnr --fps ${FPS} ${EncParamPlus}"
        EncCommand="${EncCommand} ${EncParamArg} ${EncParam}  -o ${OutputBitStream} ${InputYUV}"
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
    InputDir=`dirname ${InputYUV}`
    Command="${MP4ParserScript} ${InputDir} ${AllMP4Info} ${Pattern}"
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

runx264EncInitCRF()
{
    EncParamName="RC"
    EncParamArg="-crf "

    decalare -a aEncParam
    aEncParam=(22 23 24 25)
}

runx264EncInitProfile()
{
    EncParamName="Profile"
    EncParamPlus=""
    EncParamArg="--profile "

    aEncParam=( baseline main high high10 high422 high444 )
}

runx264EncInitLevel()
{
    EncParamName="Level"
    EncParamPlus="--profile high"
    EncParamArg="--level "

    aEncParam=(20 30 40  50 52 )
}

runx264EncMe()
{
    EncParamName="ME_NR600"
    EncParamPlus="--profile high --level 31 --nr 600"
    EncParamArg="--me"

    aEncParam=(dia hex umh  esa tesa )
}

runx264EncIFrame()
{
    EncParamName="I_NR_SceneCut"
    EncParamPlus="--profile high --level 31 -crf --nr 600"
    EncParamArg="--scenecut"

    aEncParam=(10 20 30 40 50 60 70)
}

runx264EncNoise()
{
    EncParamName="NR_0_600"
    EncParamPlus="--profile high --level 31 --crf 23"
    EncParamArg="--nr"

    aEncParam=(0 600  1000)
}

runInitForTestParams()
{
    #x264 enc param test
    #runx264EncInitCRF
    #runx264EncInitProfile
    #runx264EncInitLevel
    #runx264EncMe
    #runx264EncIFrame
    runx264EncNoise

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

