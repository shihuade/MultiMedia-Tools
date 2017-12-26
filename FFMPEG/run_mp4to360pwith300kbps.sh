#!/bin/bash
#********************************************************************************
#
#********************************************************************************

runUsage()
{
    echo -e "\033[31m *********************************** \033[0m"
    echo "   Usage:                                     "
    echo "      $0  \$InputMP4                             "
    echo -e "\033[31m *********************************** \033[0m"
}

runPareseResolutionAndFPS()
{

    ffprobe -i ${MP4File}  2>${FFLog}
    rm -f ${MP4File}_copy.mp4

    #Resolution
    # Stream #0:0(und): Video: h264 (High) (avc1 / 0x31637661), yuv420p, 448x800, 1259 kb/s, 29.92 fps, 29.92 tbr, 11488 tbn, 59.83 tbc (default)
    ResolutionInfo=`cat ${FFLog} | grep fps`
    ResolutionInfo=`echo ${ResolutionInfo} | awk 'BEGIN {FS=","} {print $3}'`
    PicW=`echo $ResolutionInfo | awk 'BEGIN {FS="x"} {print $1}'`
    PicH=`echo $ResolutionInfo | awk 'BEGIN {FS="x"} {print $2}'`

    FPSInfo=`cat ${FFLog} | grep fps | awk 'BEGIN {FS=","} {print $5}'`
    FPS=`echo ${FPSInfo} | awk 'BEGIN {FS="."} {print $1}'`
}

runPromt() {
    echo -e "\033[32m ******************************************************** \033[0m"
    echo -e "\033[32m Input  info  is: ${PicW}x${PicH} ${FPS}                  \033[0m"
    echo -e "\033[32m output info  is: ${OutPicW}x${OutPicH} ${OutFPS}         \033[0m"
    echo -e "\033[32m ******************************************************** \033[0m"
    echo -e "\033[32m RC info is: \033[0m"
    echo -e "\033[32m   -crf ${vCRF} -maxrate ${vMaxRate} -bufsize ${vBufSize} \033[0m"
    echo -e "\033[32m OutputFile is: ${OutputFile}                             \033[0m"
    echo -e "\033[32m ******************************************************** \033[0m"
    echo -e "\033[32m     FFMPEGPicCMD is: ${FFMPEGPicCMD}                     \033[0m"
    echo -e "\033[32m ******************************************************** \033[0m"
}


runScaleOutputResolutionAndFPS()
{
    let "TotalPixel = $PicW * $PicH"
    let "TotalPixel360p = 480 * 360"
    let "Factor8 = 0"
    if [ $TotalPixel -le $TotalPixel360p ]; then
        let "OutPicW = ${PicW}"
        let "OutPicH = ${PicH}"
    elif [ ${PicW} -gt ${PicH} ]; then
        let "OutPicW = 480"
        let "OutPicH = 480 * $PicH  / $PicW"
        #let picH %8 == 0
        let "Factor8 = $OutPicH / 8"
        let "OutPicH = $Factor8 * 8"
    else
        let "OutPicH = 480"
        let "OutPicW = 480 * $PicW / $PicH"

        #let picW %8 == 0
        let "Factor8 = $OutPicW / 8"
        let "OutPicW = $Factor8 * 8"
    fi

    #fps less than 25
    if [ "${FPS}" -le 25 ]; then
        let "OutFPS = $FPS"
    else
        let "OutFPS = 25"
    fi
}

runGenerateFFCMD()
{
    #ffmpeg -i 01.mp4  -c:a aac -ab 64k -c:v libx264 -preset slow -pix_fmt yuv420p -profile:v high -level 31 -crf 24 -maxrate 2000k -bufsize 4000k -r  25 -filter_complex '[0:v]scale=268:480' -movflags faststart -fflags igndts -max_interleave_delta 0 -use_editlist 0 -y 01.mp4_480x268_crf24.mp4
    vCRF="25"
    vMaxRate="2000k"
    vBufSize="4000k"

    OutputFile="${MP4File}_${OutPicW}x${OutPicH}_${OutFPS}.mp4"
    FFMPEGPicCMD="ffmpeg -i ${MP4File}  -c:a aac -ab 64k -c:v libx264 -preset slow -pix_fmt yuv420p -profile:v high -level 31 -crf ${vCRF} -maxrate ${vMaxRate} -bufsize ${vBufSize} -r ${OutFPS} -filter_complex '[0:v]scale=${OutPicW}:${OutPicH}' -movflags faststart -fflags igndts -max_interleave_delta 0 -use_editlist 0 -y ${OutputFile}"
}

runGenerate360P300kbps()
{
    ${FFMPEGPicCMD}
}

runInit()
{
    FFLog="FFMPEGCopyLog.txt"
    FFMPEGPicCMD=""

}


runCheck()
{
    let "Flag = 1"
    [ ! -e ${MP4File} ] && let "Flag = 0"
    if [ ${Flag} -eq 0 ]
    then
        echo "Input is not a file or dir, please double check"
        runUsage
        exit 1
    fi
}

runMain()
{
    runCheck

    runInit

    runPareseResolutionAndFPS
    runScaleOutputResolutionAndFPS

    runGenerateFFCMD

    runPromt

    #runGenerate360P300kbps
}

#*****************************************************
if [ $# -lt 1 ]
then
    runUsage
    exit 1
fi

MP4File=$1
runMain
#*****************************************************
