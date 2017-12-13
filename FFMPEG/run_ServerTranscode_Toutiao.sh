#!/bin/bash
#***************************************************************
# brief:
#       transcode mp4
#       and generate transcode statistic report
#***************************************************************


runUsage()
{
    echo -e "\033[31m ***************************************** \033[0m"
    echo " Usage:                                                  "
    echo "      $0  \$InputDir  \$Pattern                          "
    echo "      --InputDir: mp4 dir which files will be transcoded "
    echo "      --Pattern: file name pattern                       "
    echo -e "\033[31m ***************************************** \033[0m"
    exit 1
}

runPromptForOneMp4()
{
    echo -e "\033[32m ****************************************************** \033[0m"
    echo -e "\033[32m Mp4File      is: $Mp4File                              \033[0m"
    echo -e "\033[32m crf          is : ${vCrf}                              \033[0m"
    echo -e "\033[32m TransCommand is : $TransCommand                        \033[0m"
    echo -e "\033[32m ****************************************************** \033[0m"
}

runPromptForOneMp4Failed()
{
    echo -e "\033[31m ****************************************************** \033[0m"
    echo -e "\033[31m  Mp4File is ${Mp4File}                                 \033[0m"
    echo -e "\033[31m  Transcode checked failed!                             \033[0m"
    echo -e "\033[31m ****************************************************** \033[0m"
}

runPromptForOneMp4Succeeded()
{
    echo -e "\033[32m ************************************** \033[0m"
    echo -e "\033[32m  ffmpeg transcoded succeeded!          \033[0m"
    echo -e "\033[32m  SuccedNum is : $SuccedNum             \033[0m"
    echo -e "\033[32m ***************************************\033[0m"
}

runPromptSummary()
{
    echo -e "\033[32m ************************************************** \033[0m"
    echo -e "\033[32m  All MP4 files have been transcoded!               \033[0m"
    echo -e "\033[32m  SuccedNum is ${SuccedNum}                         \033[0m"
    echo -e "\033[32m  FailedNum is ${FailedNum}                         \033[0m"
    echo -e "\033[32m ************************************************** \033[0m"
}

runCheckTranscodeMP4()
{
    MP4CheckCommand="${MP4CheckScript} ${Mp4File} ${OutputFile}"
    echo "Parse command is $MP4CheckCommand"
    ${MP4CheckCommand}
    if [ $? -ne 0 ]; then
        runPromptForOneMp4Failed
        let "FailedNum += 1"
        return 1
    fi

    runPromptForOneMp4Succeeded
    let "SuccedNum += 1"
    return 0
}

runInitx264Sever()
{
    #AudioOpts="-c:a libfdk_aac -ab 128"
    AudioOpts="-c:a aac -ab 128k"
    VideoOpts="-c:v libx264 -preset slow -profile:v high -level 31"
    OptsPlus="-psnr -movflags faststart -use_editlist 0 "

    #P0:   ffmpeg -i In.mp4  -c:a libfdk_aac -ab 128k -c:v libx264 -preset slow -profile:v high -level 31  -g 30 -crf 24 -maxrate 4000k -bufsize 8000k -movflags faststart -y out.mp4
    #P1:   ffmpeg -i In.mp4  -c:a libfdk_aac -ab 64k  -c:v libx264 -preset slow -profile:v high -level 31  -g 30 -crf 26 -maxrate 2500k -bufsize 5000k -movflags faststart -y out.mp4
    #P14:  ffmpeg -i In.mp4  -c:a libfdk_aac -ab 64k  -c:v libx264 -preset slow -profile:v high -level 31  -g 30 -crf 30 -maxrate 2200k -bufsize 5000k -movflags faststart -y out.mp4
}

runParsePSNR()
{
    PSNRInfo=`cat ${PSNRLog} | grep "PSNR Mean Y" | sed -n '4p'`
    PSNRY=`echo $PSNRInfo | awk 'BEGIN {FS=":"} {print $2}' | awk '{print $1}' `
    PSNRU=`echo $PSNRInfo | awk 'BEGIN {FS=":"} {print $3}' | awk '{print $1}' `
    PSNRV=`echo $PSNRInfo | awk 'BEGIN {FS=":"} {print $4}' | awk '{print $1}' `
    BitRate=`echo $PSNRInfo | awk 'BEGIN {FS=":"} {print $NF}' `

    RDInfo="${BitRate}, ${PSNRY}, ${PSNRU}, ${PSNRV}"

    echo -e "\033[32m ****************************************** \033[0m"
    echo -e "\033[32m  BitRate is ${BitRate}(kbps)               \033[0m"
    echo -e "\033[32m  PSNRY   is ${PSNRY}(dB)                   \033[0m"
    echo -e "\033[32m  PSNRU   is ${PSNRU}(dB)                   \033[0m"
    echo -e "\033[32m  PSNRV   is ${PSNRV}(dB)                   \033[0m"
    echo -e "\033[32m ****************************************** \033[0m"


}


runTranscodeOne()
{
    OutputFileSuffix="${TranscodePattern}_IDR30_crf_${vCrf}"
    OutputFile="${Mp4File}_${OutputFileSuffix}.mp4"
    TransCommand="ffmpeg -xerror -i ${Mp4File} ${AudioOpts} ${VideoOpts}  ${IDROpt} ${BitRateOpt} ${OptsPlus} -y ${OutputFile}"

    runPromptForOneMp4

    ${TransCommand} 2>${PSNRLog}
    if [ $? -ne 0 ]; then
        echo -e "\033[31m  ffmpeg transcoded failed! \033[0m"
        let "FailedNum += 1"
    continue
    fi

    runParsePSNR
    runCheckTranscodeMP4
}

runTranscodeAllMP4()
{
    for Mp4File in ${InputDir}/*${Pattern}*.mp4
    do
        #for transcoded files, skip
        OriginFlag=`echo "$Mp4File" | grep "${TranscodePattern}"`
        [ -z "${OriginFlag}" ] || continue

        for vCrf in ${aCRF[@]}
        do
            #constrain IDR
            IDROpt="-g 30"
            BitRateOpt=" -maxrate 4000k -bufsize 8000k"
            runTranscodeOne
            TransRDInfo="${Mp4File}, ${vCrf},${RDInfo} "

            #adactive IDR
            IDROpt=""
            BitRateOpt=" -maxrate 4000k -bufsize 8000k"
            runTranscodeOne
            TransRDInfo="${TransRDInfo}, , ,${RDInfo} "

            echo ${TransRDInfo} >>${RDTable}
        done
    done
}


runInit()
{
    DateInfo=`date +%Y%m%d-%H-%M`
    TranscodePattern="FFTrans"
    MP4CheckScript="./run_CheckTranscodedMP4.sh"

    runInitx264Sever
    PSNRLog="psnr_log.txt"
    RDTable="RDTable_${DateInfo}.csv"
    TableHeader="File, CRF, BR, PSNRY, PSNRU, PSNRV, , , BR, PSNRY, PSNRU, PSNRV"
    echo "${TableHeader}" >${RDTable}

    aCRF=(24 26 28 30 32)
    let "SuccedNum = 0"
    let "FailedNum = 0"
}

runCheck()
{
    [ ! -d ${Input} ] && echo "Input dir doest not exist, please double check" && runUsage
}


runMain()
{
    runCheck
    runInit

    runTranscodeAllMP4
    runPromptSummary
}

#*****************************************************

if [ $# -lt 1 ]
then
    runUsage
    exit 1
fi

InputDir=$1
Pattern=$2

runMain
#*****************************************************




