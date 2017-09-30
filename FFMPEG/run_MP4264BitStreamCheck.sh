#!/bin/bash


runInint()
{
    MP4Dir="./montage-duet"

    JMLog="Log_JMDec.txt"
    FFMPEGLog="Log_FFMPEGExtract.txt"
    FailedCMD="Log_FailedCMD.txt"

    date ${JMLog}
    date ${FFMPEGLog}
    date ${FailedCMD}
}


runPromtAndUpdateForFailed()
{
    runPromptForOneFile
    echo -e "\033[31m ***************************************** \033[0m"
    echo -e "\033[31m *******Failed!  ************************* \033[0m"
    echo -e "\033[31m ***************************************** \033[0m"

    let "FailedNum += 1"
    FailedFile="${FailedFile} ${MP4File}"

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
    cat ${FailedCMD}

    echo -e "\033[31m *********************************** \033[0m"
    echo -e "\033[31m Total Num  is ${Num}                \033[0m"
    echo -e "\033[31m FailedNum  is ${FailedNum}          \033[0m"
    echo -e "\033[31m FailedFile is ${FailedFile}         \033[0m"
    echo -e "\033[31m *********************************** \033[0m"
}

runCheckOneMP4File()
{

    CMD_Bitstream="ffmpeg -i ${MP4File} -vbsf h264_mp4toannexb -vcodec copy  -f h264 -y ${BitStreamName}"
    CMD_JM="JMDecoder -p InputFile=${BitStreamName} -p OutputFile=${JMDecYUVName}"

    runPromptForOneFile

    ${CMD_Bitstream} 2>>${FFMPEGLog}
    if [ $? -ne 0 ]; then
        echo "Extract failed!"
        runPromtAndUpdateForFailed
        runPromtAndUpdateForFailed >>${FailedCMD}
    fi

     ${CMD_JM} 2>>${JMLog}
    if [ $? -ne 0 ];then
        echo "JM decoded failed!"
        runPromtAndUpdateForFailed
        runPromtAndUpdateForFailed >>${FailedCMD}
    fi
}

runCheckAllMp4()
{
    let "Num       = 0"
    let "FailedNum = 0"
    FailedFile=""

    for MP4File in ${MP4Dir}/*.mp4
    do

        BitStreamName="${MP4File}.264"
        JMDecYUVName="${MP4File}.264_JMDec.yuv"

        runCheckOneMP4File

        let "Num += 1"
    done
}



runMain()
{
    runInint

    runCheck

    runCheckAllMp4

    runPromptAll
}

#**************
runMain

