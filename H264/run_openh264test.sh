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
Command="openh264enc -org ${YUVFile} -sw ${PicW} -sh ${PicH} -fs 0  -numl 1  -numtl 1 -frin 25 -cabac 1  -dw 0 ${PicW} -dh 0 ${PicH} -frout 0 25 -bf ${BitStream}"
    echo "*************************************"
    echo " Command is ${Command}"
    echo "*************************************"

${Command}
}


runMain()
{
runInit
runTestAll
}

runMain


