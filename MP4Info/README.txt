Command for transforming 264 bit stream to mp4 file

#*******************************************************************************************
# 5 frames
#*******************************************************************************************
#default:
ffmpeg -i BasketballDrill_832x480_50.yuv_5Frames_1Slices.264 -c copy -movflags faststart BasketballDrill_832x480_50.yuv_5Frames_1Slices.264_default.mp4

ffmpeg -i BasketballDrill_832x480_50.yuv_5Frames_2Slices.264 -c copy -movflags faststart BasketballDrill_832x480_50.yuv_5Frames_2Slices.264_default.mp4

#annexb
ffmpeg -i BasketballDrill_832x480_50.yuv_5Frames_1Slices.264 -c copy -movflags faststart -bsf:v h264_mp4toannexb BasketballDrill_832x480_50.yuv_5Frames_1Slices.264_bsfannexb.mp4

ffmpeg -i BasketballDrill_832x480_50.yuv_5Frames_2Slices.264 -c copy -movflags faststart -bsf:v h264_mp4toannexb BasketballDrill_832x480_50.yuv_5Frames_2Slices.264_bsfannexb.mp4
#*******************************************************************************************
# 2 frames
#*******************************************************************************************
ffmpeg -i BasketballDrill_832x480_50.yuv_2Frames_1Slices.264 -c copy -movflags faststart BasketballDrill_832x480_50.yuv_2Frames_1Slices.264_default.mp4

ffmpeg -i BasketballDrill_832x480_50.yuv_2Frames_2Slices.264 -c copy -movflags faststart BasketballDrill_832x480_50.yuv_2Frames_2Slices.264_default.mp4
#*******************************************************************************************


#*******************************************************************************************
#encoder command
#*******************************************************************************************
./h264enc welsenc.cfg -org ../../../YUV/BasketballDrill_832x480_50.yuv -pw 832 -ph 480
#*******************************************************************************************

#*******************************************************************************************
#temp:
# mp4 binary search string
4F97D3E2785B

issue zero mp4:
000000 0000 00 FE:   32AFB42B     PPS        7E7F7B0001C0  f133  --> f3fd   Size: 02CB
       0000 10 AE: 21E7380F7F     Slice_0    622AD6295D56  f402  --> 104af  Size: 10AE
       0000 1F 0F: 210061B9CE03   Slice_1    2C628F58B210  104b4 --> 123bc  Size: 1F09

000000 0000 00 FE: 32AE353508     PPS        F47CBD7A000E  123c6 --> 12501  Size: 013C
       0000 0F A5: 21E840045F     Slice_0    67F89E13DBBE  12506 --> 134aa  Size: 0FA5
       0000 23 B7: 210061BA10     Slice_1    21C2C1F6A90F  134af --> 1585f  Size: 23B1

       ....

issue mp4:
000000 0000 00 FE:   32AFB42B     PPS        7E7F7B0001C0  f106 -->  f3d0   Size: 02CB
       0000 2F C1: 21E7380F7F     Slice_0    622AD6295D56  f3d5 -->  10482  Size: 10AE
       0000 00 01: 210061B9CE03   Slice_1    2C628F58B210  10487 --> 1238f  Size: 1F09

000000 0000 00 FE: 32AE353508     PPS        F47CBD7A000E  12399 --> 124d4  Size: 013C
       0000 33 60: 21E840045F     Slice_0    67F89E13DBBE  124d9 --> 1347d  Size: 0FA5
       0000 00 01: 210061BA10     Slice_1    21C2C1F6A90F  13482 --> 15832  Size: 23B1


#*******************************************************************************************
