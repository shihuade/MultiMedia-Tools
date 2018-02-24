#!/bin/bash

runUsage()
{
    echo -e "\033[31m ***************************************** \033[0m"
    echo " Usage:                                              "
    echo "      $0  \$InputYUV                                 "
    echo -e "\033[31m ***************************************** \033[0m"
}

runInit()
{
    ScriptYUVInfo="./run_ParseYUVInfo.sh"
}

runInitHMEncParams()
{
    HMEncoder="HMEncoder"
    Profile="main"
    Level="42"
    YUVWidth="1280"
    YUVHeight="720"
    FrameRate="30"
    FramNum="1000"

    Suffix="HMEnc"
    HMEncCfgFile="./HMConfigure/encoder_lowdelay_main.cfg"
}

runInitHMDecParams()
{
    HMDecoder="HMDecoder"
    Suffix="HMDec"
}

runPromptHMEnc()
{
    echo -e "\033[32m ****************************************************** \033[0m"
    echo -e "\033[32m InputYUV        is : $InputYUV                         \033[0m"
    echo -e "\033[32m OutputBitStream is : $OutputBitStream                  \033[0m"
    echo -e "\033[32m ReconstructYUV  is : $ReconstructYUV                   \033[0m"
    echo -e "\033[32m HMEncOption     is : $HMEncOption                      \033[0m"
    echo -e "\033[32m HMEncOptionPlus is : $HMEncOptionPlus                  \033[0m"
    echo -e "\033[32m HMEncCMD        is : $HMEncCMD                         \033[0m"
    echo -e "\033[32m ****************************************************** \033[0m"
}

runPromptHMDec()
{
    echo -e "\033[32m ****************************************************** \033[0m"
    echo -e "\033[32m InputBitStream   is : $InputBitStream                    \033[0m"
    echo -e "\033[32m OutputYUV       is : $OutputYUV                        \033[0m"
    echo -e "\033[32m HMDecOption     is : $HMDecOption                      \033[0m"
    echo -e "\033[32m HMDecCMD        is : $HMDecCMD                         \033[0m"
    echo -e "\033[32m ****************************************************** \033[0m"
}

runParseYUVFileInfo()
{
    YUVInfo=(`${ScriptYUVInfo} ${YUVFile}`)
    YUVWidth="${YUVInfo[0]}"
    YUVHeight="${YUVInfo[1]}"
    FrameRate="${YUVInfo[2]}"

    [ -z "${FrameRate}" ] && FrameRate="30"
}

runEncodeWithHM()
{

    ReconstructYUV="${OutputBitStream}_rec.yuv"

    HMEncOption="-c ${HMEncCfgFile} -wdt ${YUVWidth}  -hgt ${YUVHeight} -fr ${FrameRate} -f ${FramNum} "
    #HMEncOptionPlus="--Profile ${Profile} --Level ${Level}"
    HMEncOptionPlus=" --Level ${Level}"
    HMEncCMD="${HMEncoder}  -i ${InputYUV} ${HMEncOption} ${HMEncOptionPlus} -b ${OutputBitStream} -o ${ReconstructYUV} "

    runPromptHMEnc

    #encode with HM encoder
    ${HMEncCMD}
}

runDecodeWithHM()
{
    #HMDecOption="--OutputDecodedSEIMessagesFilename HMDec_SEI_Info.txt "
    HMDecCMD="${HMDecoder} -b ${InputBitStream} ${HMDecOption} -o ${OutputYUV} "

    runPromptHMDec
    #encode with HM encoder
    ${HMDecCMD}
}

runH265ToMP4()
{
    OutputMp4="${InputBitStream}.mp4"
    FFCommand="ffmpeg -i ${InputBitStream} -framerate ${FrameRate} -c copy  -bsf:v hevc_mp4toannexb -y ${OutputMp4}"

    echo -e "\033[32m ************************************************ \033[0m"
    echo -e "\033[32m OutputMp4 is : $OutputMp4                        \033[0m"
    echo -e "\033[32m FFCommand is : $FFCommand                        \033[0m"
    echo -e "\033[32m ************************************************ \033[0m"

    ${FFCommand}
}

runCheck()
{
    if [ ! -e ${YUVFile} ];then
        echo -e "\033[31m YUVFile not exist, please double check! \033[0m"
        exit 1
    fi
}

runMain()
{
    runInit

    #HM encoder
    InputYUV="${YUVFile}"
    OutputBitStream="${InputYUV}_${Suffix}.265"
    runInitHMEncParams
    runParseYUVFileInfo
    runEncodeWithHM

    #HM decoder
    runInitHMDecParams
    InputBitStream="${OutputBitStream}"
    OutputYUV="${InputBitStream}_${Suffix}.yuv"
    runDecodeWithHM

    runH265ToMP4
}

#****************************************************************
#YUVFile="../../../YUV/RaceHorses_832x480_30.yuv"
#BitStream="../../../YUV/RaceHorses_832x480_30.yuv_HMEnc.265"
#****************************************************************
if [ $# -lt 1 ];then
    runUsage
    exit 1
fi

YUVFile=$1
runMain




