#!/bin/bash



runUsage()
{
    echo -e "\033[31m ***************************************** \033[0m"
    echo " Usage:                                                "
    echo "      $0  \$InputMP4                                   "
    echo "                                                       "
    echo "      --InputMP4:   mp4 for preprpcessing              "
    echo "                                                       "
    echo -e "\033[31m ***************************************** \033[0m"
}

runInit()
{
    TranscodePattern="ffmpeg_PreProcess"

    MP4ParserScript="../MP4Info/run_ParseMP4Info.sh"
    AllMP4Info="Report_AllMP4Info_${PreProName}.csv"
    AllMP4InfoParserConsole="Report_AllMP4InfoDetail_${PreProName}.txt"

    PreProcReporr="Report_PreProSummary_${PreProName}.csv"

    HeadLine="PreProceParam, OriginSize(MBs), PreprocSize(MBs), Delta(%), Time(s), SHA1-Org, SHA1-Trans"

    echo "${HeadLine}">${PreProcReporr}
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

    TranscodeStatic="${PreProcParam}, ${OriginMP4Size}, ${TranscodeMP4Size}, ${DeltaRatio}"
    TranscodeStatic="${TranscodeStatic}, ${TranscodeTime}, ${SHA1Org}, ${SHA1Trans}"

    echo "${TranscodeStatic}" >>${PreProcReporr}
}

runGetAllMP4StaticInfo()
{
    InputDir=`dirname ${Mp4File}`
    Command="${MP4ParserScript} ${InputDir} ${AllMP4Info}"
    echo "Parse command is $Command"
    ${Command}
}

runDenoise()
{
    #reference: http://ffmpeg.org/ffmpeg-all.html#noise
    #inital
    #******************************************************
    declare -a aATAA=( 0.05) #0~0.3 default 0.02
    declare -a aATAB=(0.0 1.0 5.0) #0~5 default 0.04

    #opt: A=0.1 B=5.0
    PreProName="Denoise"
    runInit

    # specal for sharpen
    HeadLine="ataA, ataB, OriginSize(MBs), PreprocSize(MBs), Delta(%), Time(s), SHA1-Org, SHA1-Trans"
    echo "${HeadLine}">${PreProcReporr}

    #******************************************************

    for ataA in ${aATAA[@]}
    do
        for ataB in ${aATAB[@]}
        do
            PreProcParam="${ataA}, ${ataB}"
            OutputFile="${Mp4File}_${PreProName}_ataA_${ataA}_ataB_${ataB}.mp4"
            Command="ffmpeg -i ${Mp4File} -vf atadenoise=0a=${ataA}:0b=${ataB}:1a=${ataA}:1b=${ataB}:2a=${ataA}:2b=${ataB}"
            Command="${Command} -y ${OutputFile}"

            echo -e "\033[32m ***************************************** \033[0m"
            echo "  PreProcParam is ${PreProcParam}"
            echo "  OutputFile   is ${OutputFile}"
            echo "  Command      is ${Command}"
            echo -e "\033[32m ***************************************** \033[0m"

            StartTime=`date +%s`
            ${Command}
            EndTime=`date +%s`

            runUpdateTranscodeStatic
        done
    done


    runGetAllMP4StaticInfo >${AllMP4InfoParserConsole}
}


runSharpen()
{
    #reference: http://ffmpeg.org/ffmpeg-all.html#unsharp-1
    #inital
    #******************************************************
    declare -a aluma_msize_x=(5 9)
    declare -a aluma_msize_y=(5 9)
    declare -a aluma_amount=(0.4 0.5)

    #declare -a aluma_msize_x=(3 5 7 9 11 13 15 17 19 21 23)
    #declare -a aluma_msize_y=(3 5 7 9 11 13 15 17 19 21 23)
    #declare -a aluma_amount=(-1.5 -1.0 -0.5 0 0.5 1.0 1.5)
    #
    #opt: lx=ly=cx=cy=9, la=0.5
    PreProName="Sharpen"
    runInit

    # specal for sharpen
    HeadLine="lx, ly, la, OriginSize(MBs), PreprocSize(MBs), Delta(%), Time(s), SHA1-Org, SHA1-Trans"
    echo "${HeadLine}">${PreProcReporr}

    #******************************************************

    for lx in ${aluma_msize_x[@]}
    do
        for ly in ${aluma_msize_y[@]}
        do
            for la in ${aluma_amount[@]}
            do
                PreProcParam="${lx}, ${ly}, ${la}"
                OutputFile="${Mp4File}_${PreProName}_lx_${lx}_ly_${ly}_la_${la}_cxcyca.mp4"
                Command="ffmpeg -i ${Mp4File} -vf unsharp=lx=${lx}:ly=${ly}:la=${la}:cx=${lx}:cy=${ly}:ca=${la}"
                Command="${Command} -y ${OutputFile}"

                #ffmpeg -i SharpTest02/Sharptest.mp4 -vf unsharp=luma_msize_x=9:luma_msize_y=9:luma_amount=1.5 -y SharpTest02/Sharptest.mp4_Sharpen_lx_9_ly_9_la_1.5_cxcyca.mp4
                echo -e "\033[32m ***************************************** \033[0m"
                echo "  PreProcParam is ${PreProcParam}"
                echo "  OutputFile   is ${OutputFile}"
                echo "  Command      is ${Command}"
                echo -e "\033[32m ***************************************** \033[0m"

                StartTime=`date +%s`
                ${Command}
                EndTime=`date +%s`

                runUpdateTranscodeStatic
            done
        done
    done


    runGetAllMP4StaticInfo >${AllMP4InfoParserConsole}
}

runBright01()
{
    #*************************************************************************************
    #reference: http://ffmpeg.org/ffmpeg-all.html#colorlevels
    #           Make video output lighter: colorlevels=rimax=0.902:gimax=0.902:bimax=0.902
    #           Increase brightness:       colorlevels=romin=0.5:gomin=0.5:bomin=0.5
    #reference: http://ffmpeg.org/ffmpeg-all.html#curves-1
    #      lighter
    #      curves=lighter
    #*************************************************************************************

    #summary: BrightCommand01 > BrightCommand03 > BrightCommand02
    #inital
    #******************************************************
    declare -a aCommad
    BrightCommand01="colorlevels=rimax=0.902:gimax=0.902:bimax=0.902 "
    BrightCommand02="colorlevels=romin=0.5:gomin=0.5:bomin=0.5 "
    BrightCommand03="curves=lighter "
    aCommad[0]="${BrightCommand01}"
    aCommad[1]="${BrightCommand02}"
    aCommad[2]="${BrightCommand03}"

    PreProName="Bright01"

    runInit
    # specal for sharpen
    HeadLine="Params, OriginSize(MBs), PreprocSize(MBs), Delta(%), Time(s), SHA1-Org, SHA1-Trans"
    echo "${HeadLine}">${PreProcReporr}
    #*************************************************************************************
    let "index =0"
    for cmd in ${aCommad[@]}
    do

        PreProcParam="${cmd}"
        OutputFile="${Mp4File}_${PreProName}_command_${index}.mp4"
        Command="ffmpeg -i ${Mp4File} -vf ${cmd}  -pix_fmt yuv420p"
        Command="${Command} -y ${OutputFile}"

        echo -e "\033[32m ***************************************** \033[0m"
        echo "  PreProcParam is ${PreProcParam}"
        echo "  OutputFile   is ${OutputFile}"
        echo "  Command      is ${Command}"
        echo -e "\033[32m ***************************************** \033[0m"

        StartTime=`date +%s`
        ${Command}
        EndTime=`date +%s`

        runUpdateTranscodeStatic

        let "index ++"

    done

    runGetAllMP4StaticInfo >${AllMP4InfoParserConsole}
}

runBright02()
{
    #*************************************************************************************
    #reference: http://ffmpeg.org/ffmpeg-all.html#eq
    #      brightness -1.0~1.0
    #      gamma: 0.1~10.0
    #*************************************************************************************

    #summary:
    #inital
    #******************************************************
    declare -a aBrightness
    aBrightness=(0.0 0.1 0.2 0.3) #-1.0~ 1.0, default is 0
    PreProName="Bright02-brightness"

    runInit
    # specal for sharpen
    HeadLine="Brightness, OriginSize(MBs), PreprocSize(MBs), Delta(%), Time(s), SHA1-Org, SHA1-Trans"
    echo "${HeadLine}">${PreProcReporr}
    #*************************************************************************************
    for brightness in ${aBrightness[@]}
    do

        PreProcParam="${brightness}"
        OutputFile="${Mp4File}_${PreProName}_brightness_${brightness}.mp4"
        Command="ffmpeg -i ${Mp4File} -vf eq=brightness=${brightness} -pix_fmt yuv420p"
        Command="${Command} -y ${OutputFile}"

        echo -e "\033[32m ***************************************** \033[0m"
        echo "  PreProcParam is ${PreProcParam}"
        echo "  OutputFile   is ${OutputFile}"
        echo "  Command      is ${Command}"
        echo -e "\033[32m ***************************************** \033[0m"

        StartTime=`date +%s`
        ${Command}
        EndTime=`date +%s`

        runUpdateTranscodeStatic

    done

    runGetAllMP4StaticInfo >${AllMP4InfoParserConsole}
}


runPreAndTranscode()
{

    #inital
    #******************************************************
    declare -a aCommad
#aCommad=(-1 0 1)
#CommandParam="-deblock"
#PreProName="Deblock"

#aCommad=(0 1 2)
#CommandParam="-trellis "
#PreProName="Trellis"
# best: Trellis=2

#aCommad=(2 3 4 5)
#CommandParam="-bf "
#PreProName="BFrames"
#best 3~4

#aCommad=(3 4 5)
#CommandParam="-refs "
#PreProName="RefFrms"
# douyin ==5

#aCommad=(7 8 9)
#CommandParam="-subq "
#PreProName="subme"
#  best: 7  or 9

#aCommad=(-1 -3 -4 )
#CommandParam="-chromaoffset "
#PreProName="chromaoffset"


#OptCommand="-deblock 1 -trellis 2 -bf 4 -refs 5 -subq 9"
Label="subme_crf_24"
aCommad=(7 )
CommandParam="-subq "
CommandBR="-crf 24"


    CommandDenoise="atadenoise=0a=0.1:0b=5.0:1a=0.1:1b=5.0:2a=0.1:2b=5.0"
    CommandBright="colorlevels=rimax=0.902:gimax=0.902:bimax=0.902  -pix_fmt yuv420p"

    runInit
    # specal for transcode
    HeadLine="ChrmQPOffset, OriginSize(MBs), PreprocSize(MBs), Delta(%), Time(s), SHA1-Org, SHA1-Trans"
    echo "${HeadLine}">${PreProcReporr}
    #*************************************************************************************
    let "index =0"
    for cmd in ${aCommad[@]}
    do
#OptCommand="-deblock 1 -trellis 2 -bf 4 -refs 5 ${CommandParam} ${cmd}"
        TranscodeCMD="-c:a copy -c:v libx264 -profile:v high -level 3.1"
TranscodeCMD="${TranscodeCMD} ${OptCommand} ${CommandBR}"#  -vf ${CommandDenoise}"

        PreProcParam="${cmd}"
        OutputFile="${Mp4File}_FFMPEG_${PreProName}_${cmd}_${Label}.mp4"
        Command="ffmpeg -i ${Mp4File} ${TranscodeCMD}"
        Command="${Command}  -movflags faststart -y ${OutputFile}"

        echo -e "\033[32m ***************************************** \033[0m"
        echo "  PreProcParam is ${PreProcParam}"
        echo "  OutputFile   is ${OutputFile}"
        echo "  Command      is ${Command}"
        echo -e "\033[32m ***************************************** \033[0m"

        StartTime=`date +%s`
        ${Command}
        EndTime=`date +%s`

        runUpdateTranscodeStatic

        let "index ++"
    done

    runGetAllMP4StaticInfo >${AllMP4InfoParserConsole}
}

runCheck()
{
    let "Flag = 1"
    [ -f ${Mp4File} ] || let "Flag = 0"

    if [ ${Flag} -eq 0 ]
    then
        echo "Mp4File doest not exist, please double check"
        runUsage
        exit 1
    fi
}

runMain()
{

    runCheck
#runSharpen
#runDenoise
#runBright01
#runBright02

runPreAndTranscode
}

#*****************************************************

if [ $# -lt 1 ]
then
    runUsage
    exit 1
fi

Mp4File=$1
Pattern=$3

runMain
#*****************************************************
