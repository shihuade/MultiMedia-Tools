#!/bin/bash
#***************************************************************
# brief:
#       transcode mp4
#       and generate transcode statistic report
#***************************************************************


runUsage()
{
    echo -e "\033[31m ***************************************** \033[0m"
    echo " Usage:                                                "
    echo "      $0  \$InputDir  \$x264Params  \$Pattern          "
    echo "                                                       "
    echo "      --InputDir:   mp4 dir which will be transcoded   "
    echo "                                                       "
    echo "      --x264Params: x264 encode parameters             "
    echo "                                                       "
    echo "      --Pattern: transcoded file name's postfix        "
    echo "                                                       "
    echo -e "\033[31m ***************************************** \033[0m"
}

runInit()
{
    TranscodePattern="ffmpeg_trans"

    MP4ParserScript="../MP4Info/run_ParseMP4Info.sh"
    AllMP4Info="Report_AllMP4Info.csv"
    AllMP4InfoParserConsole="Report_AllMP4InfoDetail.txt"
    TranscodeSummaryInfo="Report_TranscodeSummary.csv"

    HeadLine="MP4File, OriginSize(MBs), TranscodedSize(MBs), Delta(%), Time(s), SHA1-Org, SHA1-Trans"

    echo "${HeadLine}">${TranscodeSummaryInfo}
}

runUpdateTranscodeStatic()
{
    #parse origin and transcoded mp4 files' info
    MP4FileName=`basename $Mp4File`

    OriginMP4Size=`ls -l ${Mp4File} | awk '{print $5}'`

    TranscodeMP4Size=`ls -l ${OutputFile} | awk '{print $5}'`

    OriginMP4Size=`echo  "scale=2; ${OriginMP4Size} / 1024 / 1024"        | bc`
    TranscodeMP4Size=`echo  "scale=2; ${TranscodeMP4Size} /1024 / 1024"   | bc`

    DeltaSize=`echo  "scale=2; ${OriginMP4Size} - ${TranscodeMP4Size}"    | bc`
    DeltaRatio=`echo  "scale=2; ${DeltaSize} / ${OriginMP4Size} * 100" | bc`


    TranscodeTime=`echo  "scale=2; ${EndTime} - ${StartTime}" | bc`

    SHA1Org=`openssl sha1 $Mp4File       | awk '{print $2}'`
    SHA1Trans=`openssl sha1 $OutputFile  | awk '{print $2}'`

    TranscodeStatic="${MP4FileName}, ${OriginMP4Size}, ${TranscodeMP4Size}, ${DeltaRatio}"
    TranscodeStatic="${TranscodeStatic}, ${TranscodeTime}, ${SHA1Org}, ${SHA1Trans}"


    echo "${TranscodeStatic}" >>${TranscodeSummaryInfo}
}


runGetAllMP4StaticInfo()
{
    Command="${MP4ParserScript} ${InputDir} ${AllMP4Info}"
    echo "Parse command is $Command"
    ${Command}
}

runTranscode()
{

    CommandDenoise="atadenoise=0a=0.1:0b=5.0:1a=0.1:1b=5.0:2a=0.1:2b=5.0"
    CommandBright="colorlevels=rimax=0.902:gimax=0.902:bimax=0.902  -pix_fmt yuv420p"
    CommandSharpen="unsharp=lx=9:ly=9:la=0.5:cx=9:cy=9:ca=0.5"
    CommandBR="-crf 21"

    for Mp4File in ${InputDir}/*.mp4
    do
        OriginFlag=`echo "$Mp4File" | grep ${TranscodePattern}`
        [ -z "${OriginFlag}" ] || continue

        OutputFile="${Mp4File}_${TranscodePattern}_${Pattern}_crf21.mp4"
        TransCommand="ffmpeg -i $Mp4File -c:a copy -c:v libx264 -profile:v high -level 3.1"
        TransCommand="$TransCommand -vf ${CommandDenoise} -vf ${CommandBright}" #-vf ${CommandSharpen}"
        TransCommand="$TransCommand ${CommandBR} ${x264Params} -movflags faststart -y $OutputFile"

        #ffmpeg -i Input.mp4 -c:a copy -c:v libx264 -profile:v high -level 3.1 -vf atadenoise=0a=0.1:0b=5.0:1a=0.1:1b=5.0:2a=0.1:2b=5.0 -vf colorlevels=rimax=0.902:gimax=0.902:bimax=0.902  -pix_fmt yuv420p -crf 21  -movflags faststart -y output.mp4

        #TransCommand="ffmpeg -i $Mp4File -c copy -y $OutputFile"

        #ffmpeg -i 1827259258.mp4 -c:a copy -c:v libx264 -profile:v high -level 3.1 -crf 24 -vf curves=lighter -pix_fmt yuv420p -y 1827259258.mp4_ligther_crf24.mp4
        echo -e "\033[32m ***************************************** \033[0m"
        echo "  Mp4File is $Mp4File"
        echo "  TransCommand is : $TransCommand"
        echo "  addition enc param is: ${x264Params}"
        echo -e "\033[32m ***************************************** \033[0m"

        StartTime=`date +%s`
        ${TransCommand}
        EndTime=`date +%s`

        runUpdateTranscodeStatic
    done
}

runPrompt()
{
    echo -e "\033[32m ************************************************************ \033[0m"
    echo "  Transcode summary report, refer to:                                    "
    echo "        --${TranscodeSummaryInfo}                                        "
    echo "  All mp4 static info, refer to:                                         "
    echo "        --${AllMP4Info}                                                  "
    echo -e "\033[32m ************************************************************ \033[0m"
}

runCheck()
{
    let "Flag = 1"
    [ -d ${Input} ] || let "Flag = 0"

    if [ ${Flag} -eq 0 ]
    then
        echo "Input dir doest not exist, please double check"
        runUsage
        exit 1
    fi

}

runMain()
{
    runCheck

    runInit

    runTranscode
    runGetAllMP4StaticInfo >${AllMP4InfoParserConsole}
    runPrompt

}

#*****************************************************

if [ $# -lt 1 ]
then
    runUsage
    exit 1
fi

InputDir=$1
x264Params=$2
Pattern=$3

runMain
#*****************************************************




