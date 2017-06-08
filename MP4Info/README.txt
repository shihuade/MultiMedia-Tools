Command for transforming 264 bit stream to mp4 file

#default:
ffmpeg -framerate 24 -i input.264 -c copy output.mp4

#annexb
ffmpeg -i BasketballDrill_832x480_50.yuv_5Frames_1Slices.264 -c copy -bsf:v h264_mp4toannexb BasketballDrill_832x480_50.yuv_5Frames_1Slices.264_bsfannexb.mp4 

