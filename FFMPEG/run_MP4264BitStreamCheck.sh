#!/bin/bash


runInint()
{
    MP4Dir="./montage-duet"
    InputMP4File="/Users/huade/Desktop/BitStreamCheck/Camera-copy-01.mp4"


    JMLog="Log_JMDec.txt"
    FFMPEGLog="Log_FFMPEGExtract.txt"
    FailedCMD="Log_FailedCMD.txt"

    date >${JMLog}
    date >${FFMPEGLog}
    date >${FailedCMD}
}


runPromtAndUpdateForFailed()
{
    echo -e "\033[31m ***************************************** \033[0m"
    echo -e "\033[31m *******MP4 check Failed!***************** \033[0m"
    echo -e "\033[31m ***************************************** \033[0m"
}

runPromptForOneFile()
{
    echo -e "\033[32m ***************************************** \033[0m"
    echo -e "\033[32m MP4File       is ${MP4File}               \033[0m"
    echo -e "\033[32m BitStreamName is ${BitStreamName}         \033[0m"
    echo -e "\033[32m JMDecYUVName  is ${JMDecYUVName}          \033[0m"
    echo -e "\033[32m CMD_Bitstream is ${CMD_Bitstream}         \033[0m"
    echo -e "\033[32m CMD_JM        is ${CMD_JM}                \033[0m"
    echo -e "\033[32m ***************************************** \033[0m"
}

runPromptAll()
{
    echo -e "\033[33m *********************************** \033[0m"
    cat ${FailedCMD}
    echo -e "\033[33m *********************************** \033[0m"

    echo -e "\033[33m *********************************** \033[0m"
    echo -e "\033[33m Total Num  is ${Num}                \033[0m"
    echo -e "\033[33m FailedNum  is ${FailedNum}          \033[0m"
    echo -e "\033[33m FailedFile is ${FailedFile}         \033[0m"
    echo -e "\033[33m *********************************** \033[0m"
}

runCheckOneMP4File()
{
    BitStreamName="${MP4File}.264"
    JMDecYUVName="${MP4File}.264_JMDec.yuv"
    CMD_Bitstream="ffmpeg -i ${MP4File} -vbsf h264_mp4toannexb -vcodec copy  -f h264 -y ${BitStreamName}"
    CMD_JM="JMDecoder -p InputFile=${BitStreamName} -p OutputFile=${JMDecYUVName}"

    runPromptForOneFile

    ${CMD_Bitstream} 2>>${FFMPEGLog}
    if [ $? -ne 0 ]; then
        echo "Extract failed!"
        runPromtAndUpdateForFailed
        runPromtAndUpdateForFailed >>${FailedCMD}
        let "FailedNum += 1"
        FailedFile="${FailedFile} ${MP4File}"
        return 1
    fi

     ${CMD_JM} 2>>${JMLog}
    if [ $? -ne 0 ];then
        echo "JM decoded failed!"
        runPromtAndUpdateForFailed
        runPromtAndUpdateForFailed >>${FailedCMD}
        let "FailedNum += 1"
        FailedFile="${FailedFile} ${MP4File}"
        return 1
    fi
}

runCheckAllMp4()
{
    let "Num       = 0"
    let "FailedNum = 0"
    FailedFile=""

    for MP4File in ${MP4Dir}/*.mp4
    do
        runCheckOneMP4File

        let "Num += 1"
    done
}


runPromptForCutOneClip()
{
    echo -e "\033[33m ******************************************* \033[0m"
    echo -e "\033[33m ********runPromptForCutOneClip************* \033[0m"
    echo -e "\033[33m ******************************************* \033[0m"
    echo -e "\033[33m ClipIndex     is ${ClipIndex}               \033[0m"
    echo -e "\033[33m ClipNum       is ${ClipNum}                 \033[0m"
    echo -e "\033[33m ClipFailedNum is ${ClipFailedNum}           \033[0m"
    echo -e "\033[33m TimeStamp     is ${TimeStamp}               \033[0m"
    echo -e "\033[33m DurationIdx   is ${DurationIdx}             \033[0m"
    echo -e "\033[33m Duration      is ${Duration}                \033[0m"
    echo -e "\033[33m MP4File       is ${MP4File}                 \033[0m"
    echo -e "\033[33m OutputFile    is ${OutputFile}              \033[0m"
    echo -e "\033[33m CMD_Clip      is ${CMD_Clip}                \033[0m"
    echo -e "\033[33m ******************************************* \033[0m"
}

runPromptForFFMPEGCutMp4Failed()
{

    echo -e "\033[31m ***************************************** \033[0m"
    echo -e "\033[31m   cut one clip failed!                   \033[0m"
    echo -e "\033[31m ***************************************** \033[0m"
    let "ClipFailedNum += 1"
    FailedIndexList="${FailedIndexList} ${ClipIndex}-${DurationIdx}"
    FailedTimeStampList="${FailedTimeStampList} ${TimeStamp}-${Duration}"

    echo -e "\033[31m ----ClipFailedNum ${ClipFailedNum} \033[0m" >>${LogForFailedCut}
    runPromptForCutOneClip >>${LogForFailedCut}
    runPromptForOneFile >>${LogForFailedCut}
}

runPromptForAllCut()
{
    echo -e "\033[31m ************************************************** \033[0m"
    echo -e "\033[31m   cut failed summary begin                         \033[0m"
    echo -e "\033[31m ************************************************** \033[0m"
    cat ${LogForFailedCut}
    echo -e "\033[31m   FailedIndexList     is ${FailedIndexList}        \033[0m"
    echo -e "\033[31m   FailedTimeStampList is ${FailedTimeStampList}    \033[0m"
    echo -e "\033[31m ************************************************** \033[0m"
    echo -e "\033[31m   cut failed summary end                           \033[0m"
    echo -e "\033[31m ************************************************** \033[0m"

    echo -e "\033[31m ************************************************** \033[0m"
    echo -e "\033[32m ClipNumSuccessNum      is ${ClipNumSuccessNum}     \033[0m"
    echo -e "\033[31m ClipFailedNum          is ${ClipFailedNum}         \033[0m"
    echo -e "\033[32m SuccessedIndexList     is ${SuccessedIndexList}    \033[0m"
    echo -e "\033[32m SuccessedTimeStampList is ${SuccessedTimeStampList}\033[0m"
    echo -e "\033[31m ************************************************** \033[0m"
}

runCutOneClip()
{
    OutputFile="${AllIOutputMP4}_Index_${i}_DurIdx_${DurationIdx}_${TimeStamp}_${Duration}.mp4"
    CMD_Clip="ffmpeg -i ${AllIOutputMP4} -ss ${TimeStamp} -t  ${Duration} -c copy -use_editlist 0 -y ${OutputFile}"
    runPromptForCutOneClip

    ${CMD_Clip} 2>${CutLog}
    [ $? -ne 0 ] && echo "cut failed!" && runPromptForFFMPEGCutMp4Failed && return 1

    MP4File="${OutputFile}"
    runCheckOneMP4File
    [ $? -ne 0 ] && echo "cut failed!" && runPromptForFFMPEGCutMp4Failed && return 1

    let "ClipNumSuccessNum += 1"
    SuccessedIndexList="${SuccessedIndexList} ${ClipIndex}-${DurationIdx}"
    SuccessedTimeStampList="${SuccessedTimeStampList} ${TimeStamp}-${Duration}"
}

runAllITranscode()
{
    AllIOutputMP4="${InputMP4File}_All_I_JP.mp4"
    #AllIOutputMP4="${InputMP4File}_I_20.mp4"
    #AllIOutputMP4="${InputMP4File}_No_B.mp4"

    #-intra -strict -2 -filter_complex color=s=480x864:c=black[bg];[0:v]scale=480:864,setsar=1:1[fg];[bg][fg]overlay=(W-w)/2:(H-h)/2:shortest=1[out] -map [out] -map 0:a -c:a copy -use_editlist 0

    #-intra -strict -2 -filter_complex color=s=480x864:c=black[bg];[0:v]scale=480:864,setsar=1:1[fg];[bg][fg]overlay=(W-w)/2:(H-h)/2:shortest=1[out] -map [out] -map 0:a -c:a copy -use_editlist 0


    #  ffmpeg -i ${InputMP4File} -c:a copy -c:v libx264 -x264opts keyint=20:min-keyint=20:bframes=0 -use_editlist 0 -y ${AllIOutputMP4}
    #    ffmpeg -i ${InputMP4File} -c:a copy -c:v libx264 -intra -use_editlist 0 -y ${AllIOutputMP4}

    ffmpeg -i ${InputMP4File} -intra -strict -2 -filter_complex 'color=s=480x864:c=black[bg];[0:v]scale=480:864,setsar=1:1[fg];[bg][fg]overlay=x=(main_w-overlay_w)/2:y=(main_h-overlay_h)/2:shortest=1[out]' -map [out] -map 0:a -c:a copy -use_editlist 0 -y ${AllIOutputMP4}

    if [ $? -ne 0 ]; then
        echo " All I transcode failed!"
        exit 1
    fi
}

runFFMPEGCutMp4()
{
    FrameInterval="0.1"
    Duration="00:00:00.10"
    CutLog="Log_FFMPEGCut.txt"
    LogForFailedCut="Log_FailedCut.txt"
    date >${LogForFailedCut}

    FailedIndexList=""
    SuccessedIndexList=""
    FailedTimeStampList=""
    SuccessedTimeStampList=""
    FailedDurationList=""
    SuccessedDutationList=""
    let "ClipIndex         = 0"
    let "ClipFailedNum     = 0"
    let "ClipNumSuccessNum = 0"
    let "ClipNum           = 8"

for((i=0; i< ${ClipNum}; i++))
#for((i=4; i< 5; i++))
    do
        TimeStamp=`echo  "scale=3; ${FrameInterval} * $i " | bc`
        IntNum=`echo ${TimeStamp} | awk 'BEGIN {FS="."} {print $1}'`
        [ "${IntNum}" = "" ] && TimeStamp="0${TimeStamp}"
        if [ ${IntNum} -lt 10 ]; then
            TimeStamp="00:00:0${TimeStamp}"
        else
            TimeStamp="00:00:${TimeStamp}"
        fi
let "DurationIdx = 0"
for((j=1; j<10; j++))
do
DurationVal=`echo  "scale=3; 0.1 * $j " | bc`
Duration="00:00:0${DurationVal}"
runCutOneClip
let "DurationIdx += 1"

done
        let "ClipIndex += 1"
    done

}


runMain()
{
    runInint

#runCheckAllMp4
#runPromptAll

runAllITranscode


runFFMPEGCutMp4
runPromptForAllCut >Log_Summary.txt
cat Log_Summary.txt
}

#**************
runMain

