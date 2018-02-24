#!/bin/bash
#***********************************************************
#  usage:
#        run_PareseX265EncLog.sh   ${x265EncLog}
#
#***********************************************************

runGetPerformanceInfo_X265()
{
    while read line
    do
        if [[ $line =~ "encoded" ]]; then
            #encoded 501 frames in 8.10s (61.84 fps), 1797.12 kb/s, Avg QP:31.52, Global PSNR: 37.427
            PSNR=`echo $line | awk 'BEGIN {FS="PSNR:"} {print $2}'`
            FPS=`echo $line | awk 'BEGIN {FS="fps"} {print $1}'`
            FPS=`echo $FPS  | awk 'BEGIN {FS="("} {print $2}'`
            BitRate=`echo $line    | awk 'BEGIN {FS="kb/s"} {print $1}'`
            BitRate=`echo $BitRate | awk 'BEGIN {FS=","} {print $2}'`
        fi
    done <${x265EncLog}

    echo "${BitRate},${PSNR},${FPS} "
}

#***********************************************************
x265EncLog=$1
#***********************************************************
if [ $# -lt 1 ]; then
    echo "usag: $0 \$x265EncLog"
    exit 1
fi

if [ ! -f ${x265EncLog} ]; then
    echo "x265EncLog does not exist, please double check!"
    exit 1
fi
#***********************************************************
runGetPerformanceInfo_X265
#***********************************************************
