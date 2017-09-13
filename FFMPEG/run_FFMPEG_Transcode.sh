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

    MP4ParserScript="../MP4Info/run_ParseMP4Info.sh"
    AllMP4Info="${InputDir}/Report_AllMP4Info_${Label}.csv"
    AllMP4InfoParserConsole="${InputDir}/Report_AllMP4InfoDetail_${Label}.txt"
    TranscodeSummaryInfo="${InputDir}/Report_TranscodeSummary_${Label}.csv"

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

runTranscodeInit()
{
    CRFParam=$1
    Label="Opt_crf_${CRFParam}"
    CommandBR="-crf ${CRFParam}"
    OptCommand="-deblock 1 -trellis 2 -bf 4 -refs 5 -subq 9"
    #OptCommand="-deblock 1 -trellis 2 -bf 4 -refs 5 -subq 9"

    CommandDenoise="atadenoise=0a=0.1:0b=5.0:1a=0.1:1b=5.0:2a=0.1:2b=5.0"
    CommandBright="colorlevels=rimax=0.902:gimax=0.902:bimax=0.902  -pix_fmt yuv420p"
    CommandSharpen="unsharp=lx=9:ly=9:la=0.5:cx=9:cy=9:ca=0.5"

    OutputFileSuffix="${TranscodePattern}"
    #**********************************
    runInit
    #**********************************

}


runx264OptParams()
{
    #x264OptsPlus="-x264opts b-adapt=2  -x264opts direct=auto -x264opts me=umh -x264opts merange=24 -x264opts  partitions=all  -x264opts subme=11  -x264opts trellis=2  -x264opts rc-lookahead=60"
    #optimization params set
    #x264Opts="-x264opts scenecut 20 -x264opts bframes 4 -x264opts b-adapt=2 -x264opts ref 5  -x264opts direct=auto -x264opts me=umh -x264opts merange=24 -x264opts  partitions=all  -x264opts subme=11  -x264opts trellis=2  -x264opts rc-lookahead=60 -x264opts qcomp=0.50 -x264opts nr 1000 -x264opts deblock 2"
    echo " above setting is time cost params setting for x264"

}

runTranscodeAll()
{

    ParamsIFrame=(30)
    ParamsBFNum=(3)
    ParamsRef=(4)
    ParamsQCom=(0.50)
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
    #   x264OptsPlus="-x264opts b-adapt=2  -x264opts direct=auto -x264opts me=umh -x264opts merange=24 -x264opts  partitions=all  -x264opts subme=11  -x264opts trellis=2  -x264opts rc-lookahead=60"

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

#OutputFileSuffix="${TranscodePattern}_${preset}_scut_${IFrame}_Bf_${BFNum}_Ref_${Ref}psy${psy}"
#OutputFileSuffix="${OutputFileSuffix}_crf_${crf}_qcom_${QCom}_nr_${NR}_debl_${Deblock}"
#OutputFileSuffix="${TranscodePattern}_${preset}_psyd_${psy}_subme_${subme}_trel_${treils}"
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


#ffmpeg -i  Test-01-NoTrans-CR10-IFrame-0s-CR8.mp4 -c:v libx264 -profile:v high -level 3.1 -x264opts scenecut=40:psy-rd=1.0,0.10:subme=8:trellis=2:direct=auto:vbv-maxrate=4000:vbv-bufsize=8000 -bf 3 -refs 4 -crf 22 -qcomp 0.56 -rc-lookahead 30 -deblock 0  -nr 0 -c:a copy -y Test-01-NoTrans-CR10-IFrame-0s-CR8.mp4_FFMPEG_V9.mp4

#ffmpeg -i  Test-01-NoTrans-CR10-IFrame-0s-CR8.mp4 -c:v libx264 -profile:v high -level 3.1 -x264opts scenecut=40:psy-rd=1.0,0.0:subme=8:trellis=2:direct=auto:vbv-maxrate=4000:vbv-bufsize=8000:pbratio=1.4 -bf 3 -refs 4 -crf 22 -qcomp 0.56 -rc-lookahead 30 -deblock 0  -nr 0 -s  -c:a copy540x960 -movflags faststart -c:a copy -y Test-01-NoTrans-CR10-IFrame-0s-CR8.mp4_FFMPEG_V9_crf21_db3-nr100.mp4

# -c:v libx264 -profile:v high -level 3.1 -x264opts scenecut=40:psy-rd=1.0,0.0:subme=8:trellis=2:direct=auto:vbv-maxrate=4000:vbv-bufsize=8000:pbratio=1.4 -bf 3 -refs 4 -crf 22 -qcomp 0.56 -rc-lookahead 30 -deblock 0  -nr 0 -s 540x960 -movflags faststart -c:a copy -y

#ffmpeg -i Test-1-1080p.mp4   -c:v libx264 -profile:v high -level 3.1 -x264opts scenecut=40:psy-rd=1.0,0.0:subme=8:trellis=2:direct=auto:vbv-maxrate=4000:vbv-bufsize=8000:ipratio=1.5 -bf 3 -refs 4 -crf 22 -qcomp 0.56 -rc-lookahead 30 -deblock 0  -nr 0 -s 540x960 -movflags faststart -c:a copy -y Test-1-1080p.mp4_pcTest_ipratio_1.5.mp4

#ffmpeg -i ~/Desktop/Test-01-1080p-allI.mp4 -c:v libx264 -profile:v high -level 3.1  -x264opts scenecut=40:psy-rd=1.0,0.00:subme=8:trellis=2:direct=auto:vbv-maxrate=4000:vbv-bufsize=8000:ipratio=1.5 -bf 3 -refs 4 -crf 20 -qcomp 0.55 -rc-lookahead 30 -deblock 0  -nr 0  -s 480x848  -c:a copy  -movflags faststart  -y  ~/Desktop/Test-01-1080p-allI.mp4_crf20_ip1.5
#
#   -c:v libx264 -preset veryfast -profile:v high -level 3.1 -x264opts scenecut=40:psy-rd=1.0,0.0:subme=4:trellis=2:ipratio=1.2 -bf 3 -refs 4 -qcomp 0.50  -rc-lookahead 20 -crf 21 -deblock 0 -nr 400  -c:a copy -movflags faststart -y

#ffmpeg -i ~/Downloads/268187939317096448_BoaIFJraSj.mp4 -c:v libx264 -preset fast -profile:v high -level 3.1 -x264opts scenecut=40:psy-rd=1.0,0.0:vbv-maxrate=4000:vbv-bufsize=8000 -bf 3 -refs 4 -qcomp 0.50  -crf 30 -deblock 4 -nr 600  -c:a copy -movflags faststart -y ~/Desktop/Test-01-crf30-db5.mp4

}


runFFMPEGTransWithFilter()
{
    echo "below is command for ffmpeg transcode with video filter"
    #ffmpeg -i Input.mp4 -c:a copy -c:v libx264 -profile:v high -level 3.1 -vf atadenoise=0a=0.1:0b=5.0:1a=0.1:1b=5.0:2a=0.1:2b=5.0 -vf colorlevels=rimax=0.902:gimax=0.902:bimax=0.902  -pix_fmt yuv420p -crf 21  -movflags faststart -y output.mp4

    #TransCommand="ffmpeg -i $Mp4File -c copy -y $OutputFile"

    #ffmpeg -i 1827259258.mp4 -c:a copy -c:v libx264 -profile:v high -level 3.1 -crf 24 -vf curves=lighter -pix_fmt yuv420p -y 1827259258.mp4_ligther_crf24.mp4
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
        TransCommand="ffmpeg -i $Mp4File ${CodecOpts} ${x264Opts} ${x264OptsPlus}"

        TransCommand="$TransCommand -y $OutputFile"

        echo -e "\033[32m ****************************************************** \033[0m"
        echo "  Mp4File is $Mp4File                                                     "
        echo "  TransCommand is : $TransCommand                                         "
        echo "  addition enc param is: ${CodecOpts} ${x264Opts} ${x264OptsPlus}         "
        echo -e "\033[32m ****************************************************** \033[0m"

        StartTime=`date +%s`
${TransCommand}
${TransCommand}
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

    runTranscodeAll
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




