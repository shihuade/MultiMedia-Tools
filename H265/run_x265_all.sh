#!/bin/bash



#extract 265 bit stream from mp4
ffmpeg -i Input.mp4 -c copy -bsf:v hevc_mp4toannexb -y Output.mp4

#generate mp4 via 265 bit stream
ffmpeg -i Input.265 -framerate 20 -c copy  -y Output.mp4

#transcode mp4 to 265 video encod mode
ffmpeg -i Input.mp4 -c:a copy -c:v libx265 -x265-params profile=main:crf=26:psy-rd=1 -y Output.mp4


#*****************************************************************************
#
# refer to: https://trac.ffmpeg.org/wiki/Debug/MacroblocksAndMotionVectors
#           https://github.com/leandromoreira/digital_video_introduction/blob/master/encoding_pratical_examples.md#generate-debug-video
#*****************************************************************************
#Analyse video with motion vetor side info
#currently, only support 264
ffmpeg -flags2 +export_mvs -i Input.mp4   -vf codecview=mv=pf+bf+bb -y Output.mp4
#*****************************************************************************
#QP
ffmpeg -debug vis_mb_type -i input.mp4 output.mp4
#*****************************************************************************
#YUV histogram
ffmpeg -i Input.mp4 -vf "split=2[a][b],[b]histogram,format=yuv420p[hh],[a][hh]overlay" Outpt.mp4
#*****************************************************************************
#media info to check detail info
mediainfo --Details=1  Input.mp4
mediainfo --Details=1  Input.mp4  | grep "slice_type I"
mediainfo --Details=1  Input.mp4  | grep "slice_type B"
mediainfo --Details=1  Input.mp4  | grep "slice_type P"
#*****************************************************************************





