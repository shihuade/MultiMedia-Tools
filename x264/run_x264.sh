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
    echo " Usage:                                                "
    echo "      $0  \$InputYUV                                   "
    echo "                                                       "
    echo "      --InputYUV:   YUV for x264 encoding              "
    echo "                                                       "
    echo -e "\033[31m ***************************************** \033[0m"
}

runInit()
{
    Pattern="x264_PreProcess"
    MP4ParserScript="../MP4Info/run_ParseMP4Info.sh"
    x264EncParserScript="./run_PareseX264EncLog.sh"
    x264EncLog=""
    x264EncPerfInfo=""

    YUVDir=`dirname ${InputYUV}`
    AllMP4Info="${YUVDir}/Report_AllMP4Info_${EncParamName}.csv"
    AllMP4InfoParserConsole="${YUVDir}/Report_AllMP4InfoDetail_${EncParamName}.txt"

    x264EncReport="${YUVDir}/Report_X264Enc_Summary_${EncParamName}.csv"

    HeadLine="EncParam, YUVSize(KBs), BitStreamSize(kBs), CR"
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


    x264EncStatic="${EncParamName}_${EncParam}, ${YUVSize}, ${BitstreamSize}, ${CompressRate}"
    x264EncStatic="${x264EncStatic}, ${x264EncPerfInfo}, ${EncodeTime}, ${SHA1Org}, ${SHA1Trans}"

    echo "${x264EncStatic}" >>${x264EncReport}
}

runx264EncInitCRF()
{
    EncParamName="RC"
    EncParamArg="-crf "
    FPS="30"

    decalare -a aEncParam
    aEncParam=(22 23 24 25)
    #***********************************************************
    #init
    runInit
    #***********************************************************
}

runx264EncInitProfile()
{
    EncParamName="Profile"
    EncParamPlus=""
    EncParamArg="--profile "
    FPS="30"

    aEncParam=( baseline main high high10 high422 high444 )
    #***********************************************************
    #init
    runInit
    #***********************************************************
}

runx264EncInitLevel()
{
    EncParamName="Level"
    EncParamPlus="--profile high"
    EncParamArg="--level "
    FPS="30"

    aEncParam=(20 30 40  50 52 )
    #***********************************************************
    #init
    runInit
    #***********************************************************
}

runx264EncMe()
{
    EncParamName="ME_NR600"
    EncParamPlus="--profile high --level 31 --nr 600"
    EncParamArg="--me"
    FPS="30"

    aEncParam=(dia hex umh  esa tesa )
    #***********************************************************
    #init
    runInit
    #***********************************************************
}

runx264EncIFrame()
{
    EncParamName="I_NR_SceneCut"
    EncParamPlus="--profile high --level 31 --nr 600"
    EncParamArg="--scenecut"
    FPS="30"

    aEncParam=(10 20 30 40 50 60 70)
    #***********************************************************
    #init
    runInit
    #***********************************************************
}

runx264EncParam()
{
    for EncParam in ${aEncParam[@]}
    do
        OutputBitStream="${InputYUV}_${EncParamName}_${EncParam}.264"
        OutputMp4="${InputYUV}_${EncParamName}_${EncParam}.264.mp4"
        x264EncLog="${InputYUV}_${EncParamName}_${EncParam}_enc.txt"
        EncCommand="x264 --psnr --fps ${FPS} ${EncParamPlus}"
        EncCommand="${EncCommand} ${EncParamArg} ${EncParam}  -o ${OutputBitStream} ${InputYUV}"
        MP4Command="ffmpeg -framerate ${FPS} -i ${OutputBitStream} -c copy -y ${OutputMp4}"

        echo -e "\033[32m ***************************************** \033[0m"
        echo "  EncParam        is ${EncParamArg} ${EncParam}"
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
    Command="${MP4ParserScript} ${InputDir} ${AllMP4Info}"
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
    if [ ! -f ${InputYUV} ]
    then
        echo "Input dir doest not exist, please double check"
        runUsage
        exit 1
    fi
}

runMain()
{
    runCheck

#x264 enc param test
#runx264EncInitCRF
#runx264EncInitProfile
#runx264EncInitLevel
#runx264EncMe
runx264EncIFrame

    runx264EncParam

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

InputYUV=$1
x264Params=$2
Pattern=$3

runMain
#*****************************************************

