#!/bin/bash

runInit()
{
#YUVFile="~//Desktop//Copy-01.mp4.264_openh264.yuv"
YUVFile="Copy-01.mp4.264_openh264.yuv"
BitStream="Test_default.264"
PicW=480
PicH=848

}

runTestAll()
{

BitStream="Test_QP26-10-3-30I_high-rc.264"
#Command="openh264enc -org ${YUVFile} -iper 30 -sw ${PicW} -sh ${PicH} -fs 0  -numl 1  -numtl 1 -frin 25 -cabac 1  -db 3  -denois 1   -scene 1  -bgd 1  -aq 1 -dw 0 ${PicW} -dh 0 ${PicH} -lqp 0 20 -ltarb 0 1000  -dprofile 0 100 -frout 0 25 -bf ${BitStream}"

#Command="openh264enc -org ${YUVFile} -iper -1 -sw ${PicW} -sh ${PicH} -fs 0  -numl 1  -numtl 1 -frin 25 -cabac 1  -denois 1  -scene 1  -bgd 1  -aq 1 -dw 0 ${PicW} -dh 0 ${PicH}  -dprofile 0 100 -frout 0 25 -maxqp 28 -minqp 10 -rc 1 -deblockIdc 0 -complexity 2 -bf ${BitStream}"
Command="openh264enc -org ${YUVFile} -iper 30 -sw ${PicW} -sh ${PicH} -fs 0  -numl 1  -numtl 1 -frin 25 -cabac 1  -denois 1  -scene 1  -bgd 1  -aq 1 -dw 0 ${PicW} -dh 0 ${PicH}  -dprofile 0 100 -frout 0 25 -maxqp 26 -minqp 10 -rc 1 -ltarb 0 1000 -deblockIdc 0 -complexity 2 -bf ${BitStream}"

    echo "*************************************"
    echo " Command is ${Command}"
    echo "*************************************"

${Command}

echo "*************************************"
echo " FFMPEG mexuer"
echo "*************************************"
ffmpeg -framerate 25 -i ${BitStream} -c copy -y ${BitStream}.mp4

}


runMain()
{
runInit
runTestAll
}

runMain


