#!/bin/bash


VideoDouYin="ios_android_douyin.mp4"
VideoMuse="ios_muse_broswer.mp4"

BitStreamDouYin="${VideoDouYin}.ffmpeg_trans.264"
BitStreamMuse="${VideoMuse}.ffmpeg_trans.264"

YUVDouYin="${VideoDouYin}.JM.dec.yuv"
YUVMuse="${VideoMuse}.JM.dec.yuv"

git clean -fdx

ffmpeg -i ${VideoDouYin} -vbsf h264_mp4toannexb -vcodec copy -an ${BitStreamDouYin} >FFMPEGTrans.log
ffmpeg -i ${VideoMuse} -vbsf h264_mp4toannexb -vcodec copy   -an ${BitStreamMuse}   >>FFMPEGTrans.log

./JMDecoder -p "InputFile=${BitStreamDouYin}" -p "OutputFile=${YUVDouYin}" >JMDec.log
./JMDecoder -p "InputFile=${BitStreamMuse}"   -p "OutputFile=${YUVMuse}"   >>>JMDec.log

