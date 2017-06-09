Command for transforming 264 bit stream to mp4 file

#default:
ffmpeg -i BasketballDrill_832x480_50.yuv_5Frames_1Slices.264 -c copy -movflags faststart BasketballDrill_832x480_50.yuv_5Frames_1Slices.264_default.mp4

ffmpeg -i BasketballDrill_832x480_50.yuv_5Frames_2Slices.264 -c copy -movflags faststart BasketballDrill_832x480_50.yuv_5Frames_2Slices.264_default.mp4

#annexb
ffmpeg -i BasketballDrill_832x480_50.yuv_5Frames_1Slices.264 -c copy -movflags faststart -bsf:v h264_mp4toannexb BasketballDrill_832x480_50.yuv_5Frames_1Slices.264_bsfannexb.mp4

ffmpeg -i BasketballDrill_832x480_50.yuv_5Frames_2Slices.264 -c copy -movflags faststart -bsf:v h264_mp4toannexb BasketballDrill_832x480_50.yuv_5Frames_2Slices.264_bsfannexb.mp4

