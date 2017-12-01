#!/bin/bash
#***************************************************************************
#  validate 265 bitstream via HM decoder
#***************************************************************************

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
    Decoder="HMDecoder"

    let "FailedNum    = 0"
    let "SucceededNum = 0"
}


runPromptHMDec()
{
    echo -e "\033[32m ****************************************************** \033[0m"
    echo -e "\033[32m SucceededNum    is : $SucceededNum                     \033[0m"
    echo -e "\033[32m FailedNum       is : $FailedNum                        \033[0m"
    echo -e "\033[32m InputBitStream  is : $InputBitStream                   \033[0m"
    echo -e "\033[32m OutputYUV       is : $OutputYUV                        \033[0m"
    echo -e "\033[32m HMDecCMD        is : $HMDecCMD                         \033[0m"
    echo -e "\033[32m HMDecCMD        is : $HMDecCMD                         \033[0m"
    echo -e "\033[32m ****************************************************** \033[0m"
}

runValidateOneStream()
{
    Suffix="HM_Dec"
    InputBitStream="${H265Stream}"
    OutputYUV="${InputBitStream}_${Suffix}.yuv"

    HMDecCMD=" "
    HMDecCMD="${Decoder} -b ${InputBitStream} ${HMDecCMD} -o ${OutputYUV}"

    runPromptHMDec

    ${HMDecCMD}
    if [ $? -eq 0 ];then
        let "SucceededNum += 1"
    else
        let "FailedNum  += 1"
    fi
}

runValidateAll()
{
    for H265Stream in ${InputBitStreamDir}/*${Pattern}*.265
    do
        runValidateOneStream
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

    runValidateAll
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

