#!/bin/bash

runUsage()
{
    echo -e "\033[31m ***************************************** \033[0m"
    echo " Usage:                                                  "
    echo "      $0  \$InputBitStreamDir  \$Pattern                 "
    echo "      --InputBitStreamDir:                               "
    echo "      --Pattern: file name pattern                       "
    echo -e "\033[31m ***************************************** \033[0m"
}

runInit()
{
    Decoder="KS265Decoder"

    let "FailedNum    = 0"
    let "SucceededNum = 0"
}


runPromptKS265Dec()
{
    echo -e "\033[32m ****************************************************** \033[0m"
    echo -e "\033[32m SucceededNum    is : $SucceededNum                     \033[0m"
    echo -e "\033[32m FailedNum       is : $FailedNum                        \033[0m"
    echo -e "\033[32m InputBitStream  is : $InputBitStream                   \033[0m"
    echo -e "\033[32m OutputYUV       is : $OutputYUV                        \033[0m"
    echo -e "\033[32m KS265DecOption  is : $KS265DecOption                   \033[0m"
    echo -e "\033[32m KS265DecCMD     is : $KS265DecCMD                      \033[0m"
    echo -e "\033[32m ****************************************************** \033[0m"
}

runKS265DecodeOneStream()
{
    Suffix="KS265_Dec"
    InputBitStream="${H265Stream}"
    OutputYUV="${InputBitStream}_${Suffix}.yuv"

    KS265DecOption=" "
    KS265DecCMD="${Decoder} -b ${InputBitStream} ${KS265DecOption} -o ${OutputYUV}"

    runPromptKS265Dec

    ${KS265DecCMD}
    if [ -$? -eq 0 ];then
        let "SucceededNum += 1"
    else
        let "FailedNum  += 1"
    fi
}

runKS265DecodeAll()
{
    for H265Stream in ${InputBitStreamDir}/*${Pattern}*.265
    do
        runKS265DecodeOneStream
    done
}

runCheck()
{
    [ ! -d ${InputBitStreamDir} ] && echo "Input dir doest not exist, please double check" && runUsage
}

runMain()
{
    runCheck

    runInit

    runKS265DecodeAll
}
#*****************************************************
if [ $# -lt 1 ]
then
    runUsage
    exit 1
fi

InputBitStreamDir=$1
Pattern=$2

runMain
#*****************************************************

