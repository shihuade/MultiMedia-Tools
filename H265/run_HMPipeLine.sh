#!/bin/bash

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
    FramNum="600"

    HMEncCfgFile="./HMConfigure/encoder_lowdelay_main.cfg"
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

    Prefix="HMEnc"
    InputYUV="${YUVFile}"
    OutputBitStream="${InputYUV}_${Prefix}.265"
    ReconstructYUV="${OutputBitStream}_rec.yuv"

    HMEncOption="-c ${HMEncCfgFile} -wdt ${YUVWidth}  -hgt ${YUVHeight} -fr ${FrameRate} -f ${FramNum} "
    #HMEncOptionPlus="--Profile ${Profile} --Level ${Level}"
    HMEncOptionPlus=" --Level ${Level}"
    HMEncCMD="${HMEncoder}  -i ${InputYUV} ${HMEncOption} ${HMEncOptionPlus} -b ${OutputBitStream} -o ${ReconstructYUV} "

    runPromptHMEnc

    #encode with HM encoder
    ${HMEncCMD}

}




runMain()
{
runInit
runInitHMEncParams
runParseYUVFileInfo
runEncodeWithHM

}

YUVFile="../../../YUV/RaceHorses_832x480_30.yuv"
runMain



