#!/bin/bash



runUsage()
{
    echo -e "\033[31m ***************************************** \033[0m"
    echo " Usage:                                                "
    echo "      $0  \$InputMP4                                   "
    echo "                                                       "
    echo "      --InputMP4:   mp4 for preprpcessing              "
    echo "                                                       "
    echo -e "\033[31m ***************************************** \033[0m"
}

runInit()
{
    TranscodePattern="ffmpeg_PreProcess"

    MP4ParserScript="../MP4Info/run_ParseMP4Info.sh"
    AllMP4Info="Report_AllMP4Info_${PreProName}.csv"
    PreProcReporr="Report_PreProSummary_${PreProName}.csv"

    HeadLine="PreProceParam, OriginSize(MBs), PreprocSize(MBs), Delta(%), Time(s), SHA1-Org, SHA1-Trans"

    echo "${HeadLine}">${PreProcReporr}
}

runUpdateTranscodeStatic()
{
    #parse origin and transcoded mp4 files' info
    MP4FileName=`basename $Mp4File`

    OriginMP4Size=`ls -l ${Mp4File} | awk '{print $5}'`

    TranscodeMP4Size=`ls -l ${OutputFile} | awk '{print $5}'`

    OriginMP4Size=`echo  "scale=2; ${OriginMP4Size} / 1024 / 1024"        | bc`
    TranscodeMP4Size=`echo  "scale=2; ${TranscodeMP4Size} /1024 / 1024"   | bc`

    DeltaSize=`echo  "scale=2; ${OriginMP4Size} - ${TranscodeMP4Size}"    | bc`
    DeltaRatio=`echo  "scale=2; ${DeltaSize} / ${OriginMP4Size} * 100" | bc`


    TranscodeTime=`echo  "scale=2; ${EndTime} - ${StartTime}" | bc`

    SHA1Org=`openssl sha1 $Mp4File       | awk '{print $2}'`
    SHA1Trans=`openssl sha1 $OutputFile  | awk '{print $2}'`

    TranscodeStatic="${PreProcParam}, ${OriginMP4Size}, ${TranscodeMP4Size}, ${DeltaRatio}"
    TranscodeStatic="${TranscodeStatic}, ${TranscodeTime}, ${SHA1Org}, ${SHA1Trans}"

    echo "${TranscodeStatic}" >>${PreProcReporr}
}

runSharpen()
{
    #inital
    #******************************************************
    declare -a aluma_msize_x=(3 5 7 9 11 13 15 17 19 21 23)
    declare -a aluma_msize_y=(3 5 7 9 11 13 15 17 19 21 23)
    declare -a aluma_amount=(-1.5 -1.0 -0.5 0 0.5 1.0 1.5)

    PreProName="Sharpen"
    runInit
    #******************************************************

    for lx in ${aluma_msize_x[@]}
    do
        for ly in ${aluma_msize_y[@]}
        do
            for la in ${aluma_amount[@]}
            do
                PreProcParam="lx-${lx}-ly ${ly}-la${la}"
                OutputFile="${PreProName}_${Mp4File}_lx_${lx}_ly_${ly}_la_${la}.mp4"
                Command="ffmpeg -i ${Mp4File} unsharp=luma_msize_x=${lx}:luma_msize_y=${ly}:luma_amount=${la}"
                Command="${Command} -y ${OutputFile}"

                echo -e "\033[32m ***************************************** \033[0m"
                echo "  PreProcParam is ${PreProcParam}"
                echo "  OutputFile   is ${OutputFile}"
                echo "  Command      is ${Command}"
                echo -e "\033[32m ***************************************** \033[0m"

                StartTime=`date +%s`
                ${Command}
                EndTime=`date +%s`

                runUpdateTranscodeStatic
            done
        done
    done
}

runCheck()
{
    let "Flag = 1"
    [ -f ${Mp4File} ] || let "Flag = 0"

    if [ ${Flag} -eq 0 ]
    then
        echo "Mp4File doest not exist, please double check"
        runUsage
        exit 1
    fi
}

runMain()
{

    runCheck
    runSharpen
}

#*****************************************************

if [ $# -lt 1 ]
then
    runUsage
    exit 1
fi

Mp4File=$1
Pattern=$3

runMain
#*****************************************************
