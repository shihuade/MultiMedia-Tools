#!/bin/bash

runUsage()
{
    echo -e "\033[31m ***************************************** \033[0m"
    echo " Usage:                                                  "
    echo "      $0  \$InputYUVDir  \$Pattern                       "
    echo "      --InputYUVDir: YUV dir which files will be encoded "
    echo "      --Pattern: file name pattern                       "
    echo -e "\033[31m ***************************************** \033[0m"
}

runInit()
{
    Encoder="KS265Encoder"
    Decoder="HMDecoder"

    Profile="main"
    Level="42"
    YUVWidth="1280"
    YUVHeight="720"
    FrameRate="30"
    FramNum="1000"

    ScriptYUVInfo="./run_ParseYUVInfo.sh"
    HMDecLog="Log_HMDec.txt"
    let "FailedNum    = 0"
    let "SucceededNum = 0"
}

runParseYUVFileInfo()
{
    YUVInfo=(`${ScriptYUVInfo} ${YUVFile}`)
    YUVWidth="${YUVInfo[0]}"
    YUVHeight="${YUVInfo[1]}"
    FrameRate="${YUVInfo[2]}"

    [  "${FrameRate}X" = "X" ] && FrameRate="30"
    return 0
}

runPromptKS265Enc()
{
    echo -e "\033[32m ****************************************************** \033[0m"
    echo -e "\033[32m SucceededNum    is : $SucceededNum                     \033[0m"
    echo -e "\033[32m FailedNum       is : $FailedNum                        \033[0m"
    echo -e "\033[32m InputYUV        is : $InputYUV                         \033[0m"
    echo -e "\033[32m FrameInfo       is : $YUVWidth x $YUVHeight $FrameRate \033[0m"
    echo -e "\033[32m OutputBitStream is : $OutputBitStream                  \033[0m"
    echo -e "\033[32m ReconstructYUV  is : $ReconstructYUV                   \033[0m"
    echo -e "\033[32m KS265EncOption  is : $KS265EncOption                   \033[0m"
    echo -e "\033[32m KS265EncCMD     is : $KS265EncCMD                      \033[0m"
    echo -e "\033[32m ****************************************************** \033[0m"
}

runKS265EncodeOneYUV()
{
    KS265DecSuffix="KS265_Enc"
    InputYUV="${YUVFile}"
    OutputBitStream="${InputYUV}_${KS265DecSuffix}.265"
    ReconstructYUV="${OutputBitStream}_rec.yuv"

    KS265EncOption="-wdt ${YUVWidth}  -hgt ${YUVHeight} -fr ${FrameRate} -frms ${FramNum} "
    KS265EncCMD="${Encoder} -i ${InputYUV} ${KS265EncOption} -b ${OutputBitStream} -o ${ReconstructYUV}"
    #KS265EncCMD="${Encoder} -i ${InputYUV} ${KS265EncOption} -b ${OutputBitStream}"

    runPromptKS265Enc

    ${KS265EncCMD}
    if [ -$? -ne 0 ];then
        let "FailedNum  += 1"
        return 1
    fi
}

runPromptHMDec()
{
    echo -e "\033[32m ****************************************************** \033[0m"
    echo -e "\033[32m *********  HM Decoder Check!  ************************ \033[0m"
    echo -e "\033[32m ****************************************************** \033[0m"
    echo -e "\033[32m SucceededNum    is : $SucceededNum                     \033[0m"
    echo -e "\033[32m FailedNum       is : $FailedNum                        \033[0m"
    echo -e "\033[32m InputBitStream  is : $InputBitStream                   \033[0m"
    echo -e "\033[32m OutputYUV       is : $OutputYUV                        \033[0m"
    echo -e "\033[32m HMDecCMD        is : $HMDecCMD                         \033[0m"
    echo -e "\033[32m ****************************************************** \033[0m"
}

runCheckWithHMDecoder()
{
    Suffix="HM_Dec"
    InputBitStream="${OutputBitStream}"
    OutputYUV="${InputBitStream}_${Suffix}.yuv"

    HMDecCMD=" "
    HMDecCMD="${Decoder} -b ${InputBitStream}  -o ${OutputYUV}"

    runPromptHMDec

    ${HMDecCMD} >${HMDecLog}
    if [ -$? -ne 0 ];then
        let "FailedNum  += 1"
        return 1
    fi

    HMDecYUVSHA=`openssl sha1 ${OutputYUV}| awk '{print $2}'`
    KSRecYUVSHA=`openssl sha1 ${ReconstructYUV}| awk '{print $2}'`

    echo -e "\033[33m HMDecYUVSHA is : $HMDecYUVSHA  \033[0m"
    echo -e "\033[33m KSRecYUVSHA is : $KSRecYUVSHA  \033[0m"

    if [ "${HMDecYUVSHA}" != "${KSRecYUVSHA}" ];then
        echo -e "\033[33m rec yuv not equal to HM dec yuv \033[0m"
        let "FailedNum  += 1"
        return 1
    fi
}

runH265ToMP4()
{
    InputBitStream="${OutputBitStream}"
    OutputMp4="${InputBitStream}.mp4"
    FFCommand="ffmpeg -i ${InputBitStream} -framerate ${FrameRate} -c copy  -bsf:v hevc_mp4toannexb -y ${OutputMp4}"

    echo -e "\033[32m ************************************************ \033[0m"
    echo -e "\033[32m OutputMp4 is : $OutputMp4                        \033[0m"
    echo -e "\033[32m FFCommand is : $FFCommand                        \033[0m"
    echo -e "\033[32m ************************************************ \033[0m"

    ${FFCommand}
}
runKS265EncodeAll()
{
    for YUVFile in ${InputYUVDir}/*${Pattern}*.yuv
    do
        Flag=`echo $YUVFile | grep KS265_Enc`
        [ ! -z "${Flag}" ] && continue
        runParseYUVFileInfo
        runKS265EncodeOneYUV
        [ $? -ne 0 ] && continue

#        runCheckWithHMDecoder
#        [ $? -ne 0 ] && continue
        runH265ToMP4
        let "SucceededNum += 1"
    done
}

promtAll()
{
    echo -e "\033[32m ****************************************************** \033[0m"
    echo -e "\033[32m SucceededNum    is : $SucceededNum                     \033[0m"
    echo -e "\033[32m FailedNum       is : $FailedNum                        \033[0m"
    echo -e "\033[32m ****************************************************** \033[0m"
}

runCheck()
{
    [ ! -d ${InputYUVDir} ] && echo "Input dir doest not exist, please double check" && runUsage
}

runMain()
{
    runCheck

    runInit

    runKS265EncodeAll

    promtAll
}
#*****************************************************
if [ $# -lt 1 ]
then
    runUsage
    exit 1
fi

InputYUVDir=$1
Pattern=$2

runMain
#*****************************************************

