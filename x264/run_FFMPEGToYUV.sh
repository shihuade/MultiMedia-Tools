#!/bin/bash
#!/bin/bash
#*********************************************************************
#  brief:
#       for x264 enc params deep learning
#       both single and combination enc parametes
#
#*********************************************************************

runUsage()
{
    echo -e "\033[31m ***************************************** \033[0m"
    echo " Usage:                                                "
    echo "      $0  \$Input \$Pattern                            "
    echo "                                                       "
    echo " example:                                              "
    echo "      $0  \$InputYUVMp4File                            "
    echo "      $0  \$InputYUVMp4Dir  \"TestSet_1\"              "
    echo "                                                       "
    echo -e "\033[31m ***************************************** \033[0m"
}

runInit()
{
    InputDir=""
    MP4File=""
    MP4Info=""
    StreamFile=""
    YUVFile=""

    PicW=""
    PicH=""
    FPS=""
    FrameNum=""

    let "MP4Num = 0"
}

runCheck()
{
    [ -d "${Input}" ] || [ -f "${Input}" ] || Flag="False"
    if [ "$Flag" = "False" ]; then
        echo -e "\033[31m ************************************************ \033[0m"
        echo -e "\033[31m Input file or dir not exist,please double check! \033[0m"
        echo -e "\033[31m ************************************************ \033[0m"
        exit 1
    fi

    [ -d "${Input}" ] && InputDir=${Input}
    [ -f "${Input}" ] && MP4File=${Input}
}

runParseMP4Info()
{
    MP4Dir=`dirname ${MP4File}`
    MP4Info="${MP4File}_mp4info.txt"
    VideoTrackInfo="${MP4Info}_video_track.txt"

    MP4ParserCommand="mp4info ${MP4File}"
    ${MP4ParserCommand} >${MP4Info}

    PicW=`cat ${MP4Info} | grep "Width:"     | awk '{print $2}'`
    PicH=`cat ${MP4Info} | grep "Height:"    | awk '{print $2}'`
    FPS=` cat ${MP4Info} | grep "frame rate" | awk '{print $4}' | awk 'BEGIN {FS="."} {print $1}'`

    egrep -i -A24 "type: *Video" ${MP4Info} >${VideoTrackInfo}
    #sample count: 1116
    FrameNum=`cat ${VideoTrackInfo}  | grep "sample count" | awk '{print $3}'`
    echo -e "\033[32m ************************************************ \033[0m"
    echo "  PicW     is: ${PicW}"
    echo "  PicH     is: ${PicH}"
    echo "  FPS      is: ${FPS}"
    echo "  FrameNum is: ${FrameNum}"
    echo "  MP4ParserCommand is ${MP4ParserCommand}"
    echo -e "\033[32m ************************************************ \033[0m"

}

runMP4ToYUV()
{
    StreamFile="${MP4File}.264"
    YUVFile="${MP4File}_${PicW}x${PicH}_${FPS}fps_FrmNum${FrameNum}.yuv"
    MP4To264CMD="ffmpeg -i ${MP4File} -vbsf h264_mp4toannexb -vcodec copy  -f h264 -y ${StreamFile}"
    DecodeCMD="JMDecoder -p InputFile=\"${StreamFile}\" -p OutputFile=\"${YUVFile}\""

    [ -e ${YUVFile} ] && echo "YUV file exist, no need to transcode!" && exit 0
    echo -e "\033[32m ************************************************ \033[0m"
    echo -e "\033[33m MP4File     is ${MP4File}                        \033[0m"
    echo -e "\033[33m StreamFile  is ${StreamFile}                     \033[0m"
    echo -e "\033[33m YUVFile     is ${YUVFile}                        \033[0m"
    echo -e "\033[33m MP4To264CMD is ${MP4To264CMD}                    \033[0m"
    echo -e "\033[33m                                                  \033[0m"
    echo -e "\033[33m DecodeCMD   is ${DecodeCMD}                      \033[0m"
    echo -e "\033[32m ************************************************ \033[0m"

    echo -e "\033[32m ************************************************ \033[0m"
    echo -e "\033[33m extracting 264 stream for mp4 file               \033[0m"
    echo -e "\033[32m ************************************************ \033[0m"
    ${MP4To264CMD}
    if [ $? -ne 0 ]; then
        echo -e "\033[31m ************************************************ \033[0m"
        echo -e "\033[31m extracted 264 stream for mp4 file failed!        \033[0m"
        echo -e "\033[31m ************************************************ \033[0m"
        exit 1
    fi

    echo -e "\033[32m ************************************************ \033[0m"
    echo -e "\033[33m decoding 264 stream to YUV file                  \033[0m"
    echo -e "\033[32m ************************************************ \033[0m"
    ${DecodeCMD}
    if [ $? -ne 0 ]; then
        echo -e "\033[31m ************************************************ \033[0m"
        echo -e "\033[31m   decoded 264 stream to YUV file failed!         \033[0m"
        echo -e "\033[31m ************************************************ \033[0m"
        exit 1
    fi

    let "MP4Num ++"
}

runAllMP4ToYUV()
{
    for MP4File in ${InputDir}/*${Pattern}*.mp4
    do
        runParseMP4Info
        runMP4ToYUV
    done
}

runPrompt()
{
    echo -e "\033[33m ********************************************* \033[0m"
    echo -e "\033[33m   MP4 files to YUV process completed!            \033[0m"
    echo -e "\033[33m   Total num is ${MP4Num}                         \033[0m"
    echo -e "\033[33m ********************************************* \033[0m"
}

runMain()
{
    runInit
    runCheck

    if [ -d "${Input}" ]; then
runAllMP4ToYUV
    else
runParseMP4Info
runMP4ToYUV
    fi

    runPrompt
}

#*************************************************************
if [ $# -lt 1 ]
then
    runUsage
    exit 1
fi

Input=$1
Pattern=$2
runMain

#*************************************************************














