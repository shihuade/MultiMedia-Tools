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

    TranscodeStatic="${MP4FileName},${OutputFileSuffix}, ${OriginMP4Size}, ${TranscodeMP4Size}, ${DeltaRatio}"
    TranscodeStatic="${TranscodeStatic}, ${TranscodeTime}, ${SHA1Org}, ${SHA1Trans}"


    echo "${TranscodeStatic}" >>${TranscodeSummaryInfo}
}


runGetAllMP4StaticInfo()
{
    Command="${MP4ParserScript} ${InputDir} ${AllMP4Info}"
    echo "Parse command is $Command"
    ${Command}
}

runTranscodeAll()
{

    ParamsIFrame=(30)
    ParamsBFNum=(3 2)
    ParamsRef=(4 2)
    ParamsQCom=(0.5)
    ParamsNR=(400)
    ParamsDeblock=(0)

    ParamsCRF=(23)

ParamsSubMe=(4)
#ParamsDirect=("none"  "spatial"  "temporal" "auto")
ParamsDirect=("auto")
ParamsTrellis=(1)
ParamsPsy=("1.0,0.15")
ParamsRCLookAhead=(30 )
ParamsRCIPRatio=(1.40)
ParamsRCPBRatio=(1.40)

#ffmpeg -ss 0.01 -i Test-01.mp4 -f image2 -vframes 1 -s 540x960  -an  -y Test_00_540x960_ss0.01.jpg

    ParamsPreset=("veryfast")
    Label=""

    #**********************************
    runInit
    #**********************************

for direct in ${ParamsDirect[@]}; do
for ipratio in ${ParamsRCIPRatio[@]}; do
for pbratio in ${ParamsRCPBRatio[@]}; do
for rclook in ${ParamsRCLookAhead[@]}; do
for subme in ${ParamsSubMe[@]}; do
for treils in ${ParamsTrellis[@]}; do
for psy in ${ParamsPsy[@]}; do
for preset in ${ParamsPreset[@]}; do
    for IFrame in ${ParamsIFrame[@]}; do
        for BFNum in ${ParamsBFNum[@]}; do
            for Ref in ${ParamsRef[@]}; do

                for QCom in ${ParamsQCom[@]}; do
                    for NR in ${ParamsNR[@]}; do
                        for Deblock in ${ParamsDeblock[@]}; do
                            for crf in ${ParamsCRF[@]}; do

CodecOpts="-c:a copy -c:v libx264 -profile:v high -level 3.1"

x264OptsFrmStruct="-x264opts scenecut=${IFrame}:psy-rd=${psy}:subme=${subme}:trellis=${treils}:pbratio=${pbratio}:ipratio=${ipratio}:vbv-maxrate=4000:vbv-bufsize=8000:direct=${direct} -bf ${BFNum}"
x264OptRC="-qcomp ${QCom}  -rc-lookahead ${rclook} -crf ${crf}"
x264OptME="-refs ${Ref}"
x264OptDeNoise="-deblock ${Deblock} -nr ${NR} -movflags faststart"
x264Opts=" ${x264OptsFrmStruct} ${x264OptRC} ${x264OptME} ${x264OptDeNoise}"

OutputFileSuffix="${TranscodePattern}_I_${IFrame}_ip_${ipratio}_bf_${BFNum}_ref_${Ref}"
OutputFileSuffix="${OutputFileSuffix}_crf_${crf}_lk_${rclook}_qc_${QCom}_nr_${NR}"
OutputFileSuffix="${OutputFileSuffix}_sme_${subme}_tr_${treils}_dr_${direct}_db_${Deblock}_psy_${psy}"

                                runTranscodeAllMP4WithOneParamSetting

                            done
                        done
                    done
                done
            done
        done
    done
done
done
done
done
done
done
done
done

#ffmpeg -i /Users/huade/Desktop/V3.3-Slow-01-copy-only.mp4 -c:a libfdk_aac -profile:a aac_he -b:a 128k -vbr 4 -c:v libx264 -profile:v high -level 3.1 -x264opts scenecut=30:subme=2:trellis=1 -bf 3 -refs 4 -rc-lookahead 20 -crf 21 -qcomp 0.52 -deblock 0 -nr 500  -movflags faststart -use_editlist 0 -y ~/Desktop/Copy-Only-ffmpeg-trans-01.mp4

}

runFFMPEGTransWithFilter()
{
    echo "below is command for ffmpeg transcode with video filter"
    #ffmpeg -i Input.mp4 -c:a copy -c:v libx264 -profile:v high -level 3.1 -vf atadenoise=0a=0.1:0b=5.0:1a=0.1:1b=5.0:2a=0.1:2b=5.0 -vf colorlevels=rimax=0.902:gimax=0.902:bimax=0.902  -pix_fmt yuv420p -crf 21  -movflags faststart -y output.mp4

    #TransCommand="ffmpeg -i $Mp4File -c copy -y $OutputFile"

    #ffmpeg -i 1827259258.mp4 -c:a copy -c:v libx264 -profile:v high -level 3.1 -crf 24 -vf curves=lighter -pix_fmt yuv420p -y 1827259258.mp4_ligther_crf24.mp4
}

runTrascodeWithMultiParamerList()
{
#ffmpeg -f avfoundation -framerate 30 -video_size 1280x720 -i "0:0" -vcodec libx264 -preset ultrafast -acodec libmp3lame -ar 44100 -ac 1 -target pal-vcd ./hello.mpg -f flv rtmp://localhost:1935/zbcs/room
#ffmpeg -f avfoundation -r 30 -video_size 1280x720 -i "0:0" -vcodec libx264 -preset ultrafast -acodec libmp3lame -ar 44100 -ac 1 -target pal-vcd ./hello.mpg -f flv rtmp://localhost:1935/zbcs/room

#ffmpeg -xerror -i /Users/huade/Desktop/Video-01//V70920-094757.mp4  -c:a copy -c:v libx264 -profile:v high -level 3.1   -x264opts scenecut=30:subme=2:trellis=1  -bf 3 -refs 4 -rc-lookahead 20 -crf 24 -qcomp 0.52 -deblock 0 -nr 500    -movflags faststart -use_editlist 0  -y /Users/huade/Desktop/Video-01//V70920-094757.mp4_FFTrans_Slow_crf24.mp4

#ffmpeg -xerror -i /Users/huade/Desktop/Video-01//V70920-094757.mp4  -c:a copy -c:v libx264 -profile:v baseline -level 3.1 -preset ultrafast  -movflags faststart -use_editlist 0  -y /Users/huade/Desktop/Video-01//V70920-094757.mp4_FFTrans_Slow_crf24.mp4

    runInit
    echo "TranscodePattern is --$TranscodePattern----"
    MP4Plus=" -movflags faststart -use_editlist 0 "
    CodecOpts=" -c:a copy -c:v libx264 -profile:v high -level 3.1 "

    #**************************************************************
    #server transcode scheme, which will be optimize
    OutputFileSuffix="${TranscodePattern}_sever"
    x264Opts=" -x264opts scenecut=30:subme=7:trellis=1 "
    x264OptsPlus=" -bf 3 -refs 4 -crf 24  -deblock 0 "
#runTranscodeAllMP4WithOneParamSetting


    OutputFileSuffix="${TranscodePattern}_Middle_crf24"
    x264Opts="  -x264opts scenecut=30:subme=0:trellis=0 "
    x264OptsPlus=" -bf 2 -refs 2 -rc-lookahead 10 -crf 24 -qcomp 0.54 -deblock 0 -nr 450 "
#    runTranscodeAllMP4WithOneParamSetting

    #**************************************************************
    OutputFileSuffix="${TranscodePattern}_Slow_crf22"
    x264Opts=" -x264opts scenecut=30:subme=2:trellis=1 "
    x264OptsPlus="-bf 3 -refs 4 -rc-lookahead 20 -crf 22 -qcomp 0.52 -deblock 0 -nr 500  "
runTranscodeAllMP4WithOneParamSetting

#**************************************************************
OutputFileSuffix="${TranscodePattern}_Slow_crf22_error"
x264Opts=" -x264opts scenecut=30:subme=2:trellis=1 "
FFMPEGOption=" -xerror"
x264OptsPlus="-bf 3 -refs 4 -rc-lookahead 20 -crf 22 -qcomp 0.52 -deblock 0 -nr 500  "
runTranscodeAllMP4WithOneParamSetting

ffmpeg  -i /Users/huade/Desktop/CopyVideo//Camera-copy-04.mp4  -c:a copy -c:v libx264 -profile:v high -level 3.1   -x264opts scenecut=30:subme=2:trellis=1  -bf 3 -refs 4 -rc-lookahead 20 -crf 22 -qcomp 0.52 -deblock 0 -nr 500    -movflags faststart -use_editlist 0  -y /Users/huade/Desktop/CopyVideo//Camera-copy-04.mp4_FFTrans_Slow_crf22.mp4

ffmpeg  -i /Users/huade/Desktop/CopyVideo//Camera-copy-04.mp4-compact.mp4  -c:a copy -c:v libx264 -profile:v high -level 3.1   -x264opts scenecut=30:subme=2:trellis=1  -bf 3 -refs 4 -rc-lookahead 20 -crf 22 -qcomp 0.52 -deblock 0 -nr 500    -movflags faststart -use_editlist 0  -y /Users/huade/Desktop/CopyVideo//Camera-copy-04.mp4-compact.mp4.ffmpeg.mp4



    OutputFileSuffix="${TranscodePattern}_SuperFast_crf26"
    x264Opts=" "
    x264OptsPlus=" -preset superfast -crf 26 "
#    runTranscodeAllMP4WithOneParamSetting


    OutputFileSuffix="${TranscodePattern}_Server_crf30"
    x264Opts=" "
    x264OptsPlus=" -deblock 0 -trellis 1 -bf 3 -refs 4 -subq 7 -crf 30  "
#    runTranscodeAllMP4WithOneParamSetting

    OutputFileSuffix="${TranscodePattern}_Server_crf24"
    x264Opts=" "
    x264OptsPlus=" -deblock 0 -trellis 1 -bf 3 -refs 4 -subq 7 -crf 24"
#    runTranscodeAllMP4WithOneParamSetting

    OutputFileSuffix="${TranscodePattern}_Superfast_crf25"
    x264Opts=" "
    x264OptsPlus="-preset superfast -crf 25"
#    runTranscodeAllMP4WithOneParamSetting

    OutputFileSuffix="${TranscodePattern}_Utrafast_crf29"
    x264Opts=" "
    x264OptsPlus="-preset ultrafast -crf 29"
#    runTranscodeAllMP4WithOneParamSetting
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
        TransCommand="ffmpeg ${FFMPEGOption} -i $Mp4File ${CodecOpts} ${x264Opts} ${x264OptsPlus} ${MP4Plus}"

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




