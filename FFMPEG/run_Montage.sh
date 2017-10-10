#!/bin/bash


runInint()
{
    MP4Dir="./montage-duet"
    InputMP4File01="/Users/huade/Desktop/Montage-Test/Camera-copy-01.mp4"
    InputMP4File02="/Users/huade/Desktop/Montage-Test/Camera-copy-03.mp4"

    MP4Dir=`dirname ${InputMP4File01}`

    MontageInputList01=""
    MontageInputList02=""

    JMLog="Log_JMDec.txt"
    FFMPEGLog="Log_FFMPEGExtract.txt"
    FailedCMD="Log_FailedCMD.txt"

    MontageCMD=""

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
    echo -e "\033[31m   cut one clip failed!                    \033[0m"
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
    OutputFile="${AllIOutputMP4}_Index_${i}_${TimeStamp}_${Duration}.mp4"
    CMD_Clip="ffmpeg -ss ${TimeStamp} -t ${Duration}  -i ${AllIOutputMP4} -c:a copy -c:v libx264 -use_editlist 0 -y ${OutputFile}"
    runPromptForCutOneClip

    ${CMD_Clip} 2>${CutLog}
    [ $? -ne 0 ] && echo "cut failed!" && runPromptForFFMPEGCutMp4Failed && exit 1

    MP4File="${OutputFile}"
    runCheckOneMP4File
    [ $? -ne 0 ] && echo "cut failed!" && runPromptForFFMPEGCutMp4Failed && exit 1

    let "ClipNumSuccessNum += 1"
    SuccessedIndexList="${SuccessedIndexList} ${ClipIndex}"
    SuccessedTimeStampList="${SuccessedTimeStampList} ${TimeStamp}-${Duration}"
}

runAllITranscode()
{
    AllIOutputMP4="${InputMP4File}_All_I.mp4"

    AllITranscodeCMD="ffmpeg -i ${InputMP4File} -intra -strict -2 -filter_complex 'color=s=480x864:c=black[bg];[0:v]scale=480:864,setsar=1:1[fg];[bg][fg]overlay=x=(main_w-overlay_w)/2:y=(main_h-overlay_h)/2:shortest=1[out]' -map [out] -map 0:a -c:a copy -c:v libx264 -use_editlist 0 -y ${AllIOutputMP4}"

    echo -e "\033[33m ************************************************** \033[0m"
    echo -e "\033[32m AllITranscodeCMD is ${AllITranscodeCMD}            \033[0m"
    echo -e "\033[33m ************************************************** \033[0m"

    ffmpeg -i ${InputMP4File} -intra -strict -2 -filter_complex 'color=s=480x864:c=black[bg];[0:v]scale=480:864,setsar=1:1[fg];[bg][fg]overlay=x=(main_w-overlay_w)/2:y=(main_h-overlay_h)/2:shortest=1[out]' -map [out] -map 0:a -c:a copy -use_editlist 0 -y ${AllIOutputMP4}
    if [ $? -ne 0 ]; then
        echo " All I transcode failed!"
        exit 1
    fi
}

runUpdateMontageFileList()
{
    let "InputListFlag = ClipIndex % 2"
    if [ ${InputIndex} -eq 0 ]
    then
        [ ${InputListFlag} -eq 0 ] && MontageInputList01="${MontageInputList01} ${OutputFile}"
    else
        [ ${InputListFlag} -eq 1 ] && MontageInputList02="${MontageInputList02} ${OutputFile}"
    fi
}

runFFMPEGCutOneMp4()
{
    FrameInterval="1.2"
    Duration="00:00:1.2"
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
    do
        TimeStamp=`echo  "scale=3; ${FrameInterval} * $i " | bc`
        IntNum=`echo ${TimeStamp} | awk 'BEGIN {FS="."} {print $1}'`
        [ "${IntNum}" = "" ] && TimeStamp="0${TimeStamp}"
        if [ ${IntNum} -lt 10 ]; then
            TimeStamp="00:00:0${TimeStamp}"
        else
            TimeStamp="00:00:${TimeStamp}"
        fi

        runCutOneClip
        runUpdateMontageFileList

        let "ClipIndex += 1"
    done
}

runMontagePrompt()
{
    echo -e "\033[32m ***************************************** \033[0m"
    echo -e "\033[32m      MontageCMD is: ${MontageCMD}         \033[0m"
    echo -e "\033[32m ***************************************** \033[0m"
}

runMontage()
{
    MontageInputList01=""
    MontageInputList02=""
    let "MontageListNum = 4"

    #cut input01 mp4 file
    let "InputIndex = 0"
    InputMP4File="${InputMP4File02}"
    runAllITranscode
    runFFMPEGCutOneMp4
    runPromptForAllCut >Log_Summary_01.txt
    cat Log_Summary_01.txt

    #cut input02 mp4 file
    let "InputIndex = 1"
    InputMP4File="${InputMP4File02}"
    runAllITranscode
    runFFMPEGCutOneMp4
    runPromptForAllCut >Log_Summary_02.txt
    cat Log_Summary_02.txt

    echo -e "\033[33m ***************************************** \033[0m"
echo -e "\033[33m      start to run montage command         \033[0m"
echo -e "\033[33m      MontageListNum     is ${MontageListNum}         \033[0m"
echo -e "\033[33m      MontageInputList02 is ${MontageInputList02}         \033[0m"
echo -e "\033[33m      MontageInputList02 is ${MontageInputList02}         \033[0m"
    echo -e "\033[33m ***************************************** \033[0m"

    aMontageInputList01=(${MontageInputList01})
    aMontageInputList02=(${MontageInputList02})
    MontageOutput="${MP4Dir}/Montage-test-out.mp4"

    for ((i=0; i<${MontageListNum}; i++))
    do
        MontageCMD="${MontageCMD} -i ${aMontageInputList01[$i]} -i ${aMontageInputList02[$i]}"
    done

    MontageCMD="ffmpeg ${MontageCMD}  -filter_complex concat=n=8 -vcodec libx264 -use_editlist 0 -c:a copy -strict -2 -y ${MontageOutput} "

    runMontagePrompt

    ${MontageCMD}
}

runMain()
{
    runInint

    runMontage
}

#**************
runMain

