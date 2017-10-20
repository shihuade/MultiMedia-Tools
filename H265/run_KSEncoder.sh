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

    Profile="main"
    Level="42"
    YUVWidth="1280"
    YUVHeight="720"
    FrameRate="30"
    FramNum="1000"

    ScriptYUVInfo="./run_ParseYUVInfo.sh"
    let "FailedNum    = 0"
    let "SucceededNum = 0"
}

runParseYUVFileInfo()
{
    YUVInfo=(`${ScriptYUVInfo} ${YUVFile}`)
    YUVWidth="${YUVInfo[0]}"
    YUVHeight="${YUVInfo[1]}"
    FrameRate="${YUVInfo[2]}"

    [ -z "${FrameRate}" ] && FrameRate="30"
}

runPromptKS265Enc()
{
    echo -e "\033[32m ****************************************************** \033[0m"
    echo -e "\033[32m SucceededNum    is : $SucceededNum                     \033[0m"
    echo -e "\033[32m FailedNum       is : $FailedNum                        \033[0m"
    echo -e "\033[32m InputYUV        is : $InputYUV                         \033[0m"
    echo -e "\033[32m OutputBitStream is : $OutputBitStream                  \033[0m"
    echo -e "\033[32m ReconstructYUV  is : $ReconstructYUV                   \033[0m"
    echo -e "\033[32m KS265EncOption  is : $KS265EncOption                   \033[0m"
    echo -e "\033[32m KS265EncCMD     is : $KS265EncCMD                      \033[0m"
    echo -e "\033[32m ****************************************************** \033[0m"
}

runKS265EncodeOneYUV()
{
    Suffix="KS265_Enc"
    InputYUV="${YUVFile}"
    OutputBitStream="${InputYUV}_${Suffix}.265"
    ReconstructYUV="${OutputBitStream}_rec.yuv"

    KS265EncOption="-wdt ${YUVWidth}  -hgt ${YUVHeight} -fr ${FrameRate} -frms ${FramNum} "
    #KS265EncCMD="${Encoder} -i ${InputYUV} ${KS265EncOption} -b ${OutputBitStream} -o ${ReconstructYUV}"
    KS265EncCMD="${Encoder} -i ${InputYUV} ${KS265EncOption} -b ${OutputBitStream}"

    runPromptKS265Enc

    ${KS265EncCMD}
    if [ -$? -eq 0 ];then
        let "SucceededNum += 1"
    else
        let "FailedNum  += 1"
    fi
}

runKS265EncodeAll()
{
    for YUVFile in ${InputYUVDir}/*.yuv
    do
        runParseYUVFileInfo
        runKS265EncodeOneYUV
    done
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

