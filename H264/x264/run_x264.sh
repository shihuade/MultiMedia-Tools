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
    FileNamePattern="x264Enc"
    MP4ParserScript="../../MP4Info/run_ParseMP4Info.sh"
    YUVInfoScript="../../H265/run_ParseYUVInfo.sh"
    x264EncParserScript="./run_PareseX264EncLog.sh"
    x264EncLog=""
    x264EncPerfInfo=""

    ReportDir="${CurDir}/Report"
    BitStreamDir="${CurDir}/BitStream"
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
    EncParamPlus="--profile high --crf 23"
    EncParamArg="--level "

    aEncParam=(20 21 22 30 31 32  40 )
}

runx264EncMe()
{
    EncParamName="ME_NR600"
    EncParamPlus="--profile high --level 31 --nr 600"
    EncParamArg="--me"

    aEncParam=(dia hex umh  esa tesa )
}


runx264EncNoise()
{
    EncParamName="NR_0_600_crf_26"
    EncParamPlus="--profile high --level 31 --crf 26"
    EncParamArg="--nr"

    aEncParam=(0 600  1000)
}

runx264EncIFrame()
{
    EncParamName="I_NoNR_SceneCut_0125"
    EncParamPlus="--profile high --level 31 --crf 23"
    EncParamArg="--scenecut"

    #scenecut I frames num increase when value increase, and the CR decrease
    #also change B frame structure
    aEncParam=(400 800)
}

runBStructure()
{
    #-b, --bframes <integer>     Number of B-frames between I and P [3]
    #--b-adapt <integer>     Adaptive B-frame decision method [1]
        #Higher values may lower threading efficiency.
        #- 0: Disabled
        #- 1: Fast
        #- 2: Optimal (slow with high --bframes)
    #--b-bias <integer>      Influences how often B-frames are used [0]
    #--b-pyramid <string>    Keep some B-frames as references [normal]
        #- none: Disabled
        #- strict: Strictly hierarchical pyramid
        #- normal: Non-strict (not Blu-ray compatible)
    #--open-gop              Use recovery points to close GOPs
    #    Only available with b-frames

    EncParamName="BStructure_OpenGOP_NR"
    EncParamPlus="--profile high --level 31 --crf 23 --bframes 3 "
    EncParamArg=""

    #--b-adapt =2 will be very slow and CR not sure to enhance
    #--bframes 在渐变场景，B帧并不是也多越好，越多，B帧的压缩率会大幅降低
    #          在快速切换的场景，B帧多略优
    #--b-pyramid  =1 或者2 时，参考帧B帧的图像质量较差，参考压缩效率降低，整体压缩性能不一定提升
    #--b-bias -90～100， 越大，B帧倾向性越大，但是，B帧越大，B帧的压缩比会降低，总体压缩性能不一定提升，甚至降低
    #--open-gop 测试结果显示，压缩比没有变化，但是编码时间会增加
    aEncParam[0]="--nr 600"
    aEncParam[1]="--open-gop --nr 600"
}


runx264EncRCMode()
{
    EncParamName="RC_AQTest_CRF23"
    EncParamPlus="--profile high --level 31 --crf 23"
    EncParamArg="--aq-mode "

    #CQP 模式，文件大小不恒定
    #CBR 模式，码率控制较好，但是视频质量变化大
    #MaxQP， 目前36和40相同，但当前参数设置基本和36相似，质量相似
    #--qcomp  默认0.6， 越小，mbtree权重越大，压缩比越高， 建议选择0.5～0.6之间的
    aEncParam=( 0 1 2 3  )
}

runx264EncSkip()
{
    EncParamName="EarlySkip_CRF23"
    EncParamPlus="--profile high --level 31"
    EncParamArg=" "

    #默认打开，P_SKIP MV 快速决策，测试集显示，对编码效率有提升
    aEncParam[0]=" --crf 23 --no-fast-pskip"
    aEncParam[1]=" --crf 23"
}

runx264EncWeight()
{
    EncParamName="WeightP_CRF23"
    EncParamPlus="--profile high --level 31"
    EncParamArg="--weightp "

    #--no-weightb 默认打开B帧加权，对编码效率有提升，但不明显，时间相近
    #--weightbp  默认2, P帧加权，对编码效率有提升，时间增加10%左右
    #aEncParam[0]=" --crf 23 "
    aEncParam=(0 1 2)
}

runx264EncRef()
{
    EncParamName="Ref_CRF23"
    EncParamPlus="--profile high --level 31 --crf 23"
    EncParamArg="--ref "

    aEncParam=(2 3 4 5)
}

runx264EncDeblocking()
{
    EncParamName="Deblock_CRF23"
    EncParamPlus="--profile high --level 31 --crf 23"
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

runFFMPEGx264()
{
    X264Options="-x264opts keyint=123:min-keyint=20 "
    FFMPEGCMD="ffmpeg -i final.mp4 -c:a copy -c:v libx264  -crf 24  ${X264Options} -y final.mp4.ffmpegx264_crf24.mp4"

    FFMPEGCMD="ffmpeg -i final.mp4 -c:a copy -c:v libx264  -profile:v high -level 31 -crf 24 -x264opts keyint=123:min-keyint=20  -x264opts nr=600 -y final.mp4.ffmpegx264_crf24_02_nr600.mp4"
}

runInitForTestParams()
{
    #x264 enc param test
    #runx264EncInitCRF
    #runx264EncInitProfile
    #runx264EncInitLevel
    #runx264EncMe
#runx264EncNoise
#runx264EncIFrame
#runBStructure
#runx264EncRCMode
#runx264EncSkip

#runx264EncWeight
#runx264EncInitLevel
#runx264EncRef

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

