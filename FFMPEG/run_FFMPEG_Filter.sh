#!/bin/bash
#***************************************************************
# brief:
#       ffmpeg filter complex test
#
#***************************************************************


runUsage()
{
    echo -e "\033[31m ***************************************** \033[0m"
    echo " Usage:                                                "
    echo "      $0  \$InputDir                \$Pattern          "
    echo "                                                       "
    echo "      --InputDir:   mp4 dir which will be transcoded   "
    echo "                                                       "
    echo "      --Pattern: transcoded file name's  suffix        "
    echo "                                                       "
    echo -e "\033[31m ***************************************** \033[0m"
}

runInit()
{
    TranscodePattern="FFTrans"
    TimeInfo=`date +%Y%m%d-%H%M`

    MP4ParserScript="../MP4Info/run_ParseMP4Info.sh"
    AllMP4Info="${InputDir}/Report_AllMP4Info_${Label}.csv"
    AllMP4InfoParserConsole="${InputDir}/Report_AllMP4InfoDetail_${Label}.txt"
    TranscodeSummaryInfo="${InputDir}/Report_TranscodeSummary_${Label}_${TimeInfo}.csv"

    HeadLine="MP4File, Params, OriginSize(MBs), TranscodedSize(MBs), Delta(%), Time(s), SHA1-Org, SHA1-Trans"

    echo "${HeadLine}">${TranscodeSummaryInfo}
}


runTranscodeAllMP4WithOneParamSetting()
{

    for Mp4File in ${InputDir}/*${Pattern}*.mp4
    do

        #for transcoded files, skip
        OriginFlag=`echo "$Mp4File" | grep "${TranscodePattern}"`
        [ -z "${OriginFlag}" ] || continue

        #for non "*Import*" file, trans
        #OriginFlag=`echo "$Mp4File" | grep "Import"`
        #[ -z "${OriginFlag}" ] &&  continue

        #for "*org*" file, skip
        #ExcludeFlag=`echo "$Mp4File" | grep "default"`
        #[ -z "${ExcludeFlag}" ] || continue

        OutputFile="${Mp4File}_${OutputFileSuffix}.mp4"
        TransCommand="ffmpeg -i $Mp4File ${CodecOpts} ${x264Opts} ${x264OptsPlus} ${MP4Plus}"

        TransCommand="$TransCommand -y $OutputFile"

        echo -e "\033[32m ****************************************************** \033[0m"
        echo "  Mp4File is $Mp4File                                                     "
        echo "  TransCommand is : $TransCommand                                         "
        echo "  addition enc param is: ${CodecOpts} ${x264Opts} ${x264OptsPlus}         "
        echo -e "\033[32m ****************************************************** \033[0m"

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

#runTranscodeAll
    runTrascodeWithMultiParamerList
    runPrompt

}

#*****************************************************

if [ $# -lt 1 ]
then
    runUsage
    exit 1
fi

InputDir=$1
Pattern=$2

runMain
#*****************************************************




