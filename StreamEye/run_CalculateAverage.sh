#!/bin/bash

runUsage()
{
    echo "**********************************************************"
    echo "**********************************************************"
    echo "  Usage:                                                  "
    echo "     $0  \${StaticSCVFile}  \${DataPatterns}              "
    echo "         \${DataPatterns}:  patterns for mp4 file name    "
    echo "          example:                                        "
    echo "             douyin parse all douyin's *douyin*.mp4 data  "
    echo "             muse   parse all muse's   *muse*.mp4 data    "
    echo "             'douyin  muse'                               "
    echo "                   parse all douyin's/muse's data         "
    echo ""
    echo "**********************************************************"
    echo "**********************************************************"
}

runInitVar()
{
    #Mp4 file size
    let "MP4FileSize = 0"

    #MP4 video PSNR
    let "VideoPSNR = 0"

    #Frame num
    let " FrameNumAll = 0"
    let " FrameNumI   = 0"
    let " FrameNumP   = 0"
    let " FrameNumB   = 0"

    let "FrameNumRatioI = 0"
    let "FrameNumRatioP = 0"
    let "FrameNumRatioB = 0"

    #frame size statistic
    let " FrameSizeAll = 0"
    let " FrameSizeI   = 0"
    let " FrameSizeP   = 0"
    let " FrameSizeB   = 0"

    let " FrameSizeRatioI = 0"
    let " FrameSizeRatioP = 0"
    let " FrameSizeRatioB = 0"

    let " FrameSizeAvg  = 0"
    let " FrameSizeAvgI = 0"
    let " FrameSizeAvgP = 0"
    let " FrameSizeAvgB = 0"

    let " FrameSizeMaxI = 0"
    let " FrameSizeMaxP = 0"
    let " FrameSizeMaxB = 0"

    let " FrameSizeMinI = 0"
    let " FrameSizeMinP = 0"
    let " FrameSizeMinB = 0"

    #compress ratio
    let "FrameCompressedRatio  = 0"
    let "FrameCompressedRatioI = 0"
    let "FrameCompressedRatioP = 0"
    let "FrameCompressedRatioB = 0"

    #bit rate statistic
    let " BitRateAvg       = 0"
    let " BitRateAvgFPS30  = 0"

    let " BitRateIn1S = 0"
    let " BitRateIn2S = 0"
    let " BitRateIn3S = 0"
    let " BitRateIn4S = 0"
    let " BitRateIn5S = 0"
    let " BitRateIn6S = 0"

    #PSNR statistic
    let " FramePSNRAvg = 0"
    let " FramePSNRI   = 0"
    let " FramePSNRP   = 0"
    let " FramePSNRB   = 0"

    let " FramePSNRMaxI =0"
    let " FramePSNRMaxP =0"
    let " FramePSNRMaxB =0"

    let " FramePSNRMinI =0"
    let " FramePSNRMinP =0"
    let " FramePSNRMinB =0"


    #frame QP statistic
    let " FrameQPAvg = 0"
    let " FrameQPI   = 0"
    let " FrameQPP   = 0"
    let " FrameQPB   = 0"

    let " FrameQPMaxI =0"
    let " FrameQPMaxP =0"
    let " FrameQPMaxB =0"

    let " FrameQPMinI =0"
    let " FrameQPMinP =0"
    let " FrameQPMinB =0"
}

runInit()
{
    AverageFile="EncoderParametersAverage.csv"
    Headline="EncodeParam, Average"

    echo ${Headline}>${AverageFile}

    runInitVar

    declare -a aPatternList
    aPatternList=("")

    let "DataNum = 0"
}

#table header for sequence in run_ParseStreamEyeIndexCSV.sh
runInitHeadLineSequence()
{
    #headline for output statistic table
    SequenceHeadLine1_Basic="Basic info, , , , , , ,"
    SequenceHeadLine2_Basic="profile, level, EncM, Resol, FrRate, Dura,PSNR,"
    SequenceHeadLine1_Frame="FrameNum,,,,  FrameRatio(%),,,FrameSize,,,,CompressedRatio(%),,,, QP, , ,"
    SequenceHeadLine2_Frame="All, I, P, B, I,  P,  B,  Avg, I, P, B,  Avg,  I,  P,  B,  Avg, Max, Min,"

    SequenceHeadLine1="${SequenceHeadLine1_Basic} ${SequenceHeadLine1_Frame}"
    SequenceHeadLine2="${SequenceHeadLine2_Basic} ${SequenceHeadLine2_Frame}"

    echo "MP4, , ${SequenceHeadLine1} ${FrameHeadline1}"  >${DetailStaticFile}
    echo "MP4, Filesize(MB), ${SequenceHeadLine2} ${FrameHeadline2}" >>${DetailStaticFile}

}

#table header for frame in run_ParseStreamEyeIndexCSV.sh
runInitHeadLineFrame()
{
    #28
    #headline for output statistic table
    FrameHeadline1_Num="FrmNum,,,,FrmNumRatio(%),,,"
    FrameHeadline2_Num="All,I,P,B, I, P, B,"

    #35
    FrameHeadline1_Size="FrmSize(Byte),,,, FrmSizeRatio(%),,,AvgSize(Byte),,,,MaxSize(Byte),,,MinSize(Byte),,,"
    FrameHeadline2_Size="All, I, P, B, I, P, B, Avg, I, P, B, I, P, B, I, P, B,"

    #52
    FrameHeadline1_CR="Compressed Ratio, , , ,"
    FrameHeadline2_CR="Avg, I, P, B ,"

    #56
    FrameHeadline1_BitRate="Bit Rate(kbps), , , , , , , ,"
    FrameHeadline2_BitRate="avg, avgfps30, 1s, 2s, 3s, 4s, 5s, 6s,"
    #64
    FrameHeadline1_PSNR="Frame PSNR(db), , , , , , , , , ,"
    FrameHeadline2_PSNR="Avg, I, P, B, MaxI, MaxP, MaxB, MinI, MinP, MinB,"
    #74
    FrameHeadline1_QP="Frame QP, , , , , , , , , ,"
    FrameHeadline2_QP="Avg, I, P, B, MaxI, MaxP, MaxB, MinI, MinP, MinB"

    FrameHeadline1="${FrameHeadline1_Num} ${FrameHeadline1_Size} ${FrameHeadline1_CR} ${FrameHeadline1_BitRate} ${FrameHeadline1_PSNR} ${FrameHeadline1_QP}"
    FrameHeadline2="${FrameHeadline2_Num} ${FrameHeadline2_Size} ${FrameHeadline2_CR} ${FrameHeadline2_BitRate} ${FrameHeadline2_PSNR} ${FrameHeadline2_QP}"
}

runParseAndUpdateData_Basic()
{
    #Sequence data var :offset 1,  num, 26
    #Frame data var num:offset 27, num, CF=3*26 + F - 27 = 57

    vMP4FileSize=`echo "$line" | awk 'BEGIN {FS=","} {print $2}'`
    MP4FileSize=` echo "scale=2; ${MP4FileSize} + ${vMP4FileSize}" | bc`

    vVideoPSNR=`echo "$line" | awk 'BEGIN {FS=","} {print $9}'`
    VideoPSNR=`echo  "scale=2; ${VideoPSNR} + ${vVideoPSNR}" | bc`
}

runParseAndUpdateData_FrameNum()
{
    #Frame data var num:offset 27, num, CF=3*26 + F - 27 = 57
    #Frame num
    vFrameNumAll=`echo "$line" | awk 'BEGIN {FS=","} {print $28}'`
    FrameNumAll=`echo  "scale=2; ${VideoPSNR} + ${vFrameNumAll}" | bc`

    vFrameNumI=`echo "$line" | awk 'BEGIN {FS=","} {print $29}'`
    FrameNumI=`echo  "scale=2; ${FrameNumI} + ${vFrameNumI}" | bc`

    vFrameNumP=`echo "$line" | awk 'BEGIN {FS=","} {print $30}'`
    FrameNumP=`echo  "scale=2; ${FrameNumP} + ${vFrameNumP}" | bc`

    vFrameNumB=`echo "$line" | awk 'BEGIN {FS=","} {print $31}'`
    FrameNumB=`echo  "scale=2; ${FrameNumB} + ${vFrameNumB}" | bc`

    #frame num ratio
    FrameNumRatioI=`echo "$line" | awk 'BEGIN {FS=","} {print $32}'`
    FrameNumRatioI=`echo "scale=2; ${FrameNumRatioI} + ${vFrameNumI}" | bc`

    vFrameNumRatioP=`echo "$line" | awk 'BEGIN {FS=","} {print $33}'`
    FrameNumRatioP=`echo  "scale=2; ${FrameNumRatioP} + ${vFrameNumRatioP}" | bc`

    vFrameNumRatioB=`echo "$line" | awk 'BEGIN {FS=","} {print $34}'`
    FrameNumRatioB=`echo  "scale=2; ${FrameNumRatioB} + ${vFrameNumRatioB}" | bc`
}

runParseAndUpdateData_FrameSize()
{
    #overall frame size statistic
    vFrameSizeAll=`echo "$line" | awk 'BEGIN {FS=","} {print $35}'`
    FrameSizeAll=`echo  "scale=2; ${FrameSizeAll} + ${vFrameSizeAll}" | bc`

    vFrameSizeI=`echo "$line" | awk 'BEGIN {FS=","} {print $36}'`
    FrameSizeI=`echo  "scale=2; ${FrameSizeI} + ${vFrameSizeI}" | bc`

    vFrameSizeP=`echo "$line" | awk 'BEGIN {FS=","} {print $37}'`
    FrameSizeP=`echo  "scale=2; ${FrameSizeP} + ${vFrameSizeP}" | bc`

    vFrameSizeB=`echo "$line" | awk 'BEGIN {FS=","} {print $38}'`
    FrameSizeB=`echo  "scale=2; ${FrameSizeB} + ${vFrameSizeB}" | bc`

    #overall frame size ratio
    vFrameSizeRatioI=`echo "$line" | awk 'BEGIN {FS=","} {print $39}'`
    FrameSizeRatioI=`echo  "scale=2; ${FrameSizeRatioI} + ${vFrameSizeRatioI}" | bc`

    vFrameSizeRatioP=`echo "$line" | awk 'BEGIN {FS=","} {print $40}'`
    FrameSizeRatioP=`echo  "scale=2; ${FrameSizeRatioP} + ${vFrameSizeRatioP}" | bc`

    vFrameSizeRatioB=`echo "$line" | awk 'BEGIN {FS=","} {print $41}'`
    FrameSizeRatioB=`echo  "scale=2; ${FrameSizeRatioB} + ${vFrameSizeRatioB}" | bc`

    #frame size
    vFrameSizeAvg=`echo "$line" | awk 'BEGIN {FS=","} {print $42}'`
    FrameSizeAvg=`echo  "scale=2; ${FrameSizeAvg} + ${vFrameSizeAvg}" | bc`

    vFrameSizeAvgI=`echo "$line" | awk 'BEGIN {FS=","} {print $43}'`
    FrameSizeAvgI=`echo  "scale=2; ${FrameSizeAvgI} + ${vFrameSizeAvgI}" | bc`

    vFrameSizeAvgP=`echo "$line" | awk 'BEGIN {FS=","} {print $44}'`
    FrameSizeAvgP=`echo  "scale=2; ${FrameSizeAvgP} + ${vFrameSizeAvgP}" | bc`

    vFrameSizeAvgB=`echo "$line" | awk 'BEGIN {FS=","} {print $45}'`
    FrameSizeAvgB=`echo  "scale=2; ${FrameSizeAvgB} + ${vFrameSizeAvgB}" | bc`

    #max frame size
    vFrameSizeMaxI=`echo "$line" | awk 'BEGIN {FS=","} {print $46}'`
    FrameSizeMaxI=`echo  "scale=2; ${FrameSizeMaxI} + ${vFrameSizeMaxI}" | bc`

    vFrameSizeMaxP=`echo "$line" | awk 'BEGIN {FS=","} {print $47}'`
    FrameSizeMaxP=`echo  "scale=2; ${FrameSizeMaxP} + ${vFrameSizeMaxP}" | bc`

    vFrameSizeMaxB=`echo "$line" | awk 'BEGIN {FS=","} {print $48}'`
    FrameSizeMaxB=`echo  "scale=2; ${FrameSizeMaxB} + ${vFrameSizeMaxB}" | bc`

    #min frame size
    vFrameSizeMinI=`echo "$line" | awk 'BEGIN {FS=","} {print $49}'`
    FrameSizeMinI=`echo  "scale=2; ${FrameSizeMinI} + ${vFrameSizeMinI}" | bc`

    vFrameSizeMinP=`echo "$line" | awk 'BEGIN {FS=","} {print $50}'`
    FrameSizeMinP=`echo  "scale=2; ${FrameSizeMinP} + ${vFrameSizeMinP}" | bc`

    vFrameSizeMinB=`echo "$line" | awk 'BEGIN {FS=","} {print $51}'`
    FrameSizeMinB=`echo  "scale=2; ${FrameSizeMinB} + ${vFrameSizeMinB}" | bc`
}

runParseAndUpdateData_CompressRatio()
{
    #compress ratio
    vFrameCompressedRatio=`echo "$line" | awk 'BEGIN {FS=","} {print $52}'`
    FrameCompressedRatio=`echo  "scale=2; ${FrameCompressedRatio} + ${vFrameCompressedRatio}" | bc`

    vFrameCompressedRatioI=`echo "$line" | awk 'BEGIN {FS=","} {print $53}'`
    FrameCompressedRatioI=`echo  "scale=2; ${FrameCompressedRatioI} + ${vFrameCompressedRatioI}" | bc`

    vFrameCompressedRatioP=`echo "$line" | awk 'BEGIN {FS=","} {print $54}'`
    FrameCompressedRatioP=`echo  "scale=2; ${FrameCompressedRatioP} + ${vFrameCompressedRatioP}" | bc`

    vFrameCompressedRatioB=`echo "$line" | awk 'BEGIN {FS=","} {print $55}'`
    FrameCompressedRatioB=`echo  "scale=2; ${FrameCompressedRatioB} + ${vFrameCompressedRatioB}" | bc`

}

runParseAndUpdateData_Bitrate()
{
    #bit rate statistic
    vBitRateAvg=`echo "$line" | awk 'BEGIN {FS=","} {print $56}'`
    BitRateAvg=`echo  "scale=2; ${BitRateAvg} + ${vBitRateAvg}" | bc`

    vBitRateAvgFPS30=`echo "$line" | awk 'BEGIN {FS=","} {print $57}'`
    BitRateAvgFPS30=`echo  "scale=2; ${BitRateAvgFPS30} + ${vBitRateAvgFPS30}" | bc`

    vBitRateIn1S=`echo "$line" | awk 'BEGIN {FS=","} {print $58}'`
    BitRateIn1S=`echo  "scale=2; ${BitRateIn1S} + ${vBitRateIn1S}" | bc`

    vBitRateIn2S=`echo "$line" | awk 'BEGIN {FS=","} {print $59}'`
    BitRateIn2S=`echo  "scale=2; ${BitRateIn2S} + ${vBitRateIn2S}" | bc`

    vBitRateIn3S=`echo "$line" | awk 'BEGIN {FS=","} {print $60}'`
    BitRateIn3S=`echo  "scale=2; ${BitRateIn3S} + ${vBitRateIn3S}" | bc`

    vBitRateIn4S=`echo "$line" | awk 'BEGIN {FS=","} {print $61}'`
    BitRateIn4S=`echo  "scale=2; ${BitRateIn4S} + ${vBitRateIn4S}" | bc`

    vBitRateIn5S=`echo "$line" | awk 'BEGIN {FS=","} {print $62}'`
    BitRateIn5S=`echo  "scale=2; ${BitRateIn5S} + ${vBitRateIn5S}" | bc`

    vBitRateIn6S=`echo "$line" | awk 'BEGIN {FS=","} {print $63}'`
    BitRateIn6S=`echo  "scale=2; ${BitRateIn6S} + ${vBitRateIn6S}" | bc`
}

runParseAndUpdateData_PSNR()
{
    #PSNR statistic
    vFramePSNRAvg=`echo "$line" | awk 'BEGIN {FS=","} {print $64}'`
    FramePSNRAvg=`echo  "scale=2; ${FramePSNRAvg} + ${vFramePSNRAvg}" | bc`

    vFramePSNRI=`echo "$line" | awk 'BEGIN {FS=","} {print $65}'`
    FramePSNRI=`echo  "scale=2; ${FramePSNRI} + ${vFramePSNRI}" | bc`

    vFramePSNRP=`echo "$line" | awk 'BEGIN {FS=","} {print $66}'`
    FramePSNRP=`echo  "scale=2; ${FramePSNRP} + ${vFramePSNRP}" | bc`

    vFramePSNRB=`echo "$line" | awk 'BEGIN {FS=","} {print $67}'`
    FramePSNRB=`echo  "scale=2; ${FramePSNRB} + ${vFramePSNRB}" | bc`

    #max PSNR
    vFramePSNRMaxI=`echo "$line" | awk 'BEGIN {FS=","} {print $68}'`
    FramePSNRMaxI=`echo  "scale=2; ${FramePSNRMaxI} + ${vFramePSNRMaxI}" | bc`

    vFramePSNRMaxP=`echo "$line" | awk 'BEGIN {FS=","} {print $69}'`
    FramePSNRMaxP=`echo  "scale=2; ${FramePSNRMaxP} + ${vFramePSNRMaxP}" | bc`

    vFramePSNRMaxB=`echo "$line" | awk 'BEGIN {FS=","} {print $70}'`
    FramePSNRMaxB=`echo  "scale=2; ${FramePSNRMaxB} + ${vFramePSNRMaxB}" | bc`

    #min PSNR
    vFramePSNRMinI=`echo "$line" | awk 'BEGIN {FS=","} {print $71}'`
    FramePSNRMinI=`echo  "scale=2; ${FramePSNRMinI} + ${vFramePSNRMinI}" | bc`

    vFramePSNRMinP=`echo "$line" | awk 'BEGIN {FS=","} {print $72}'`
    FramePSNRMinP=`echo  "scale=2; ${FramePSNRMinP} + ${vFramePSNRMinP}" | bc`

    vFramePSNRMinB=`echo "$line" | awk 'BEGIN {FS=","} {print $73}'`
    FramePSNRMinB=`echo  "scale=2; ${FramePSNRMinB} + ${vFramePSNRMinB}" | bc`
}

runParseAndUpdateData_QP()
{
    #frame QP statistic
    vFrameQPAvg=`echo "$line" | awk 'BEGIN {FS=","} {print $74}'`
    FrameQPAvg=`echo  "scale=2; ${FrameQPAvg} + ${vFrameQPAvg}" | bc`

    vFrameQPI=`echo "$line" | awk 'BEGIN {FS=","} {print $75}'`
    FrameQPI=`echo  "scale=2; ${FrameQPI} + ${vFrameQPI}" | bc`

    vFrameQPP=`echo "$line" | awk 'BEGIN {FS=","} {print $76}'`
    FrameQPP=`echo  "scale=2; ${FrameQPP} + ${vFrameQPP}" | bc`

    vFrameQPB=`echo "$line" | awk 'BEGIN {FS=","} {print $77}'`
    FrameQPB=`echo  "scale=2; ${FrameQPB} + ${vFrameQPB}" | bc`

    #max frame QP
    vFrameQPMaxI=`echo "$line" | awk 'BEGIN {FS=","} {print $78}'`
    FrameQPMaxI=`echo  "scale=2; ${FrameQPMaxI} + ${vFrameQPMaxI}" | bc`

    vFrameQPMaxP=`echo "$line" | awk 'BEGIN {FS=","} {print $79}'`
    FrameQPMaxP=`echo  "scale=2; ${FrameQPMaxP} + ${vFrameQPMaxP}" | bc`

    vFrameQPMaxB=`echo "$line" | awk 'BEGIN {FS=","} {print $80}'`
    FrameQPMaxB=`echo  "scale=2; ${FrameQPMaxB} + ${vFrameQPMaxB}" | bc`

    #min frame QP
    vFrameQPMinI=`echo "$line" | awk 'BEGIN {FS=","} {print $81}'`
    FrameQPMinI=`echo  "scale=2; ${FrameQPMinI} + ${vFrameQPMinI}" | bc`

    vFrameQPMinP=`echo "$line" | awk 'BEGIN {FS=","} {print $82}'`
    FrameQPMinP=`echo  "scale=2; ${FrameQPMinP} + ${vFrameQPMinP}" | bc`

    vFrameQPMinB=`echo "$line" | awk 'BEGIN {FS=","} {print $83}'`
    FrameQPMinB=`echo  "scale=2; ${FrameQPMinB} + ${vFrameQPMinB}" | bc`

}

runCalculateAverage()
{
    #Mp4 file size
    MP4FileSize=`echo  "scale=2; ${MP4FileSize} / ${DataNum}" | bc`

    #MP4 video PSNR
    VideoPSNR=`echo  "scale=2; ${VideoPSNR} / ${DataNum}" | bc`

    #Frame num
    FrameNumAll=`echo  "scale=2; ${FrameNumAll} / ${DataNum}" | bc`
    FrameNumI=`echo  "scale=2; ${FrameNumI} / ${DataNum}" | bc`
    FrameNumP=`echo  "scale=2; ${FrameNumP} / ${DataNum}" | bc`
    FrameNumB=`echo  "scale=2; ${FrameNumB} / ${DataNum}" | bc`

    FrameNumRatioI=`echo  "scale=2; ${FrameNumRatioI} / ${DataNum}" | bc`
    FrameNumRatioP=`echo  "scale=2; ${FrameNumRatioP} / ${DataNum}" | bc`
    FrameNumRatioB=`echo  "scale=2; ${FrameNumRatioB} / ${DataNum}" | bc`

    #video size
    FrameSizeAll=`echo  "scale=2; ${FrameSizeAll} / ${DataNum}" | bc`
    FrameSizeI=`echo  "scale=2; ${FrameSizeI} / ${DataNum}" | bc`
    FrameSizeP=`echo  "scale=2; ${FrameSizeP} / ${DataNum}" | bc`
    FrameSizeB=`echo  "scale=2; ${FrameSizeB} / ${DataNum}" | bc`

    FrameSizeRatioI=`echo  "scale=2; ${FrameSizeRatioI} / ${DataNum}" | bc`
    FrameSizeRatioP=`echo  "scale=2; ${FrameSizeRatioP} / ${DataNum}" | bc`
    FrameSizeRatioB=`echo  "scale=2; ${FrameSizeRatioB} / ${DataNum}" | bc`

    #frame size
    FrameSizeAvg=`echo  "scale=2; ${FrameSizeAvg} / ${DataNum}" | bc`
    FrameSizeAvgI=`echo  "scale=2; ${FrameSizeAvgI} / ${DataNum}" | bc`
    FrameSizeAvgP=`echo  "scale=2; ${FrameSizeAvgP} / ${DataNum}" | bc`
    FrameSizeAvgB=`echo  "scale=2; ${FrameSizeAvgB} / ${DataNum}" | bc`

    FrameSizeMaxI=`echo  "scale=2; ${FrameSizeMaxI} / ${DataNum}" | bc`
    FrameSizeMaxP=`echo  "scale=2; ${FrameSizeMaxP} / ${DataNum}" | bc`
    FrameSizeMaxB=`echo  "scale=2; ${FrameSizeMaxB} / ${DataNum}" | bc`

    FrameSizeMinI=`echo  "scale=2; ${FrameSizeMinI} / ${DataNum}" | bc`
    FrameSizeMinP=`echo  "scale=2; ${FrameSizeMinP} / ${DataNum}" | bc`
    FrameSizeMinB=`echo  "scale=2; ${FrameSizeMinB} / ${DataNum}" | bc`

    #compress ratio
    FrameCompressedRatio=`echo  "scale=2; ${FrameCompressedRatio} / ${DataNum}" | bc`
    FrameCompressedRatioI=`echo  "scale=2; ${FrameCompressedRatioI} / ${DataNum}" | bc`
    FrameCompressedRatioP=`echo  "scale=2; ${FrameCompressedRatioP} / ${DataNum}" | bc`
    FrameCompressedRatioB=`echo  "scale=2; ${FrameCompressedRatioB} / ${DataNum}" | bc`

    #bit rate statistic
    BitRateAvg=`echo  "scale=2; ${BitRateAvg} / ${DataNum}" | bc`
    BitRateAvgFPS30=`echo  "scale=2; ${BitRateAvgFPS30} / ${DataNum}" | bc`

    BitRateIn1S=`echo  "scale=2; ${BitRateIn1S} / ${DataNum}" | bc`
    BitRateIn2S=`echo  "scale=2; ${BitRateIn2S} / ${DataNum}" | bc`
    BitRateIn3S=`echo  "scale=2; ${BitRateIn3S} / ${DataNum}" | bc`
    BitRateIn4S=`echo  "scale=2; ${BitRateIn4S} / ${DataNum}" | bc`
    BitRateIn5S=`echo  "scale=2; ${BitRateIn5S} / ${DataNum}" | bc`
    BitRateIn6S=`echo  "scale=2; ${BitRateIn6S} / ${DataNum}" | bc`

    #PSNR statistic
    FramePSNRAvg=`echo  "scale=2; ${FramePSNRAvg} / ${DataNum}" | bc`
    FramePSNRI=`echo  "scale=2; ${FramePSNRI} / ${DataNum}" | bc`
    FramePSNRP=`echo  "scale=2; ${FramePSNRP} / ${DataNum}" | bc`
    FramePSNRB=`echo  "scale=2; ${FramePSNRB} / ${DataNum}" | bc`

    FramePSNRMaxI=`echo  "scale=2; ${FramePSNRMaxI} / ${DataNum}" | bc`
    FramePSNRMaxP=`echo  "scale=2; ${FramePSNRMaxP} / ${DataNum}" | bc`
    FramePSNRMaxB=`echo  "scale=2; ${FramePSNRMaxB} / ${DataNum}" | bc`

    FramePSNRMinI=`echo  "scale=2; ${FramePSNRMinI} / ${DataNum}" | bc`
    FramePSNRMinP=`echo  "scale=2; ${FramePSNRMinP} / ${DataNum}" | bc`
    FramePSNRMinB=`echo  "scale=2; ${FramePSNRMinB} / ${DataNum}" | bc`

    #frame QP statistic
    FrameQPAvg=`echo  "scale=2; ${FrameQPAvg} / ${DataNum}" | bc`
    FrameQPI=`echo  "scale=2; ${FrameQPI} / ${DataNum}" | bc`
    FrameQPP=`echo  "scale=2; ${FrameQPP} / ${DataNum}" | bc`
    FrameQPB=`echo  "scale=2; ${FrameQPB} / ${DataNum}" | bc`

    FrameQPMaxI=`echo  "scale=2; ${FrameQPMaxI} / ${DataNum}" | bc`
    FrameQPMaxP=`echo  "scale=2; ${FrameQPMaxP} / ${DataNum}" | bc`
    FrameQPMaxB=`echo  "scale=2; ${FrameQPMaxB} / ${DataNum}" | bc`

    FrameQPMinI=`echo  "scale=2; ${FrameQPMinI} / ${DataNum}" | bc`
    FrameQPMinP=`echo  "scale=2; ${FrameQPMinP} / ${DataNum}" | bc`
    FrameQPMinB=`echo  "scale=2; ${FrameQPMinB} / ${DataNum}" | bc`
}

runParseAndUpdateData()
{
    runParseAndUpdateData_Basic

    runParseAndUpdateData_FrameNum
    runParseAndUpdateData_FrameSize

    runParseAndUpdateData_CompressRatio
    runParseAndUpdateData_Bitrate

    runParseAndUpdateData_PSNR
    runParseAndUpdateData_QP
}

runOutput()
{
    #basic info
    echo -e " MP4FileSize, $MP4FileSize \n VideoPSNR, $VideoPSNR"

    #Frame num
    echo -e " FrameNumAll, $FrameNumAll \n FrameNumI, $FrameNumI \n FrameNumP, $FrameNumP \n FrameNumB, $FrameNumB"
    echo -e " FrameNumRatioI, $FrameNumRatioI \n FrameNumRatioP, $FrameNumRatioP \n FrameNumRatioB, $FrameNumRatioB"

    #video size
    echo -e " FrameSizeAll, $FrameSizeAll \n FrameSizeI, $FrameSizeI \n FrameSizeP, $FrameSizeP \n FrameSizeB, $FrameSizeB"
    echo -e " FrameSizeRatioI, $FrameSizeRatioI \n FrameSizeRatioP, $FrameSizeRatioP \n FrameSizeRatioB, $FrameSizeRatioB"

    #frame size
    echo -e " FrameSizeAvg, $FrameSizeAvg \n FrameSizeAvgI, $FrameSizeAvgI \n FrameSizeAvgP, $FrameSizeAvgP \n FrameSizeAvgB, $FrameSizeAvgB"
    echo -e " FrameSizeMaxI, $FrameSizeMaxI \n FrameSizeMaxP, $FrameSizeMaxP \n FrameSizeMaxB, $FrameSizeMaxB"
    echo -e " FrameSizeMinI, $FrameSizeMinI \n FrameSizeMinP, $FrameSizeMinP \n FrameSizeMinB, $FrameSizeMinB"

    #compress ratio
    echo -e " FrameCompressedRatio, $FrameCompressedRatio \n FrameCompressedRatioI, $FrameCompressedRatioI \n FrameCompressedRatioP, $FrameCompressedRatioP \n FrameCompressedRatioB, $FrameCompressedRatioB"

    #bit rate statistic
    echo -e " BitRateAvg, $BitRateAvg \n BitRateAvgFPS30, $BitRateAvgFPS30"
    echo -e " BitRateIn1S, $BitRateIn1S \n BitRateIn2S, $BitRateIn2S \n BitRateIn3S, $BitRateIn3S"
    echo -e " BitRateIn4S, $BitRateIn4S \n BitRateIn5S, $BitRateIn5S \n BitRateIn6S, $BitRateIn6S"

    #PSNR statistic
    echo -e " FramePSNRAvg, $FramePSNRAvg \n FramePSNRI, $FramePSNRI \n FramePSNRP, $FramePSNRP \n FramePSNRB, $FramePSNRB"
    echo -e " FramePSNRMaxI, $FramePSNRMaxI \n FramePSNRMaxP, $FramePSNRMaxP \n FramePSNRMaxB, $FramePSNRMaxB"
    echo -e " FramePSNRMinI, $FramePSNRMinI \n FramePSNRMinP, $FramePSNRMinP \n FramePSNRMinB, $FramePSNRMinB"

    #frame QP statistic
    echo -e " FrameQPAvg, $FrameQPAvg \n FrameQPI, $FrameQPI \n FrameQPP, $FrameQPP \n FrameQPB, $FrameQPB"
    echo -e " FrameQPMaxI, $FrameQPMaxI \n FrameQPMaxP, $FrameQPMaxP \n FrameQPMaxB, $FrameQPMaxB"
    echo -e " FrameQPMinI, $FrameQPMinI \n FrameQPMinP, $FrameQPMinP \n FrameQPMinB, $FrameQPMinB"
}

runSumofVarForAllData()
{
    while read line
    do

        let  "MatchFlag = 0"
        [[ "$line" =~ ".mp4" ]] && let  "MatchFlag = 1"

        [ ${MatchFlag} -eq 0 ] && continue

        runParseAndUpdateData
        let "DataNum += 1"
    done <${StaticCSVFile}
}

runSumofVarForAllPatterns()
{
    while read line
    do
        for vpattern in ${aPatternList[@]}
        do
            FilePattern=${vpattern}

            let  "MatchFlag = 0"
            [[ "$line" =~ "${FilePattern}" ]] && let  "MatchFlag = 1"

            [ ${MatchFlag} -eq 0 ] && continue

            runParseAndUpdateData
            let "DataNum += 1"
        done
    done  <${StaticCSVFile}
}

runCheck()
{
    echo "**************************************************"
    echo "**************************************************"
    echo " checking input parameters...                     "
    echo " StaticCSVFile  is  ${StaticCSVFile}              "
    echo " DataPatterns   is  ${DataPatterns}               "
    echo "**************************************************"
    echo "**************************************************"

    if [ ! -e ${StaticCSVFile} ]
    then
        echo "StaticCSVFile does not exist, please double check!"
        exit 1
    fi

    if [ ! -z "${DataPatterns}" ]
    then
        aPatternList=(${DataPatterns})
    fi
}

runMain()
{
    runInit
    runCheck

    if [ ! -z "${DataPatterns}" ]
    then
        runSumofVarForAllPatterns
    else
        runSumofVarForAllData
    fi

    if [ ${DataNum} -gt 0 ]
    then
        runCalculateAverage
    fi

    runOutput >>${AverageFile}
    cat ${AverageFile}

    if [ ${DataNum} -eq 0 ]
    then
        echo "**************************************************"
        echo "  no data match pattern: ${DataPatterns}          "
        echo "**************************************************"
    fi
}

#**********************************************************
#**********************************************************
if [ $# -lt 1 ]
then
    runUsage
    exit 1
fi

StaticCSVFile=$1
DataPatterns=$2

runMain





