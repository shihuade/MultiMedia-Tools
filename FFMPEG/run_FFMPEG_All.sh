#!/bin/bash

#*****************************************************************************
#   ffmpeg install on mac
#*****************************************************************************
configuration: --cc=/usr/bin/clang --prefix=/opt/ffmpeg --extra-version=tessus --enable-avisynth --enable-fontconfig --enable-gpl --enable-libass --enable-libbluray --enable-libfreetype --enable-libgsm --enable-libmodplug --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libopus --enable-libsnappy --enable-libsoxr --enable-libspeex --enable-libtheora --enable-libvidstab --enable-libvo-amrwbenc --enable-libvorbis --enable-libvpx --enable-libwavpack --enable-libx264 --enable-libx265 --enable-libxavs --enable-libxvid --enable-libzmq --enable-libzvbi --enable-version3 --disable-ffplay --disable-indev=qtkit --enable-libopenjpeg --enable-libvpx --enable-libxavs --enable-libopenh264 --enable-libx264 --enable-libx265 --enable-libkvazaar --enable-libilbc --enable-libwavpack

#actual configure on mac
./configure --cc=/usr/bin/clang --prefix=/opt/ffmpeg --extra-version=tessus --enable-avisynth --enable-fontconfig --enable-gpl --enable-libass --enable-libbluray --enable-libfreetype --enable-libgsm --enable-libmodplug --enable-libmp3lame  --enable-libopus --enable-libsnappy --enable-libsoxr --enable-libspeex --enable-libtheora --enable-libvidstab  --enable-libvorbis --enable-libvpx --enable-libwavpack --enable-libx264 --enable-libx265 --enable-libxvid --enable-libzmq --enable-version3 --disable-ffplay --disable-indev=qtkit --enable-libopenjpeg  --enable-libkvazaar --enable-libilbc  --enable-libfdk-aac --enable-nonfree --enable-encoder=aac --enable-libwebp


#transcode only(mini ffmpeg)
./configure --cc=/usr/bin/clang --prefix=/opt/ffmpeg --extra-version=tessus --enable-gpl --enable-nonfree --disable-avdevice --disable-swresample --disable-swresample --disable-swscale --disable-postproc --disable-avfilter --disable-network --disable-dwt --disable-lsp --disable-lzo --disable-mdct --disable-rdft --disable-fft --disable-faan --disable-pixelutils --enable-libx264   --enable-libfdk-aac --enable-encoder=aac --disable-ffplay --disable-indev=qtkit

#*****************************************************************************
#   #ffmpeg to webp
#*****************************************************************************
#clip mp4
# ffmpeg -i input.mp4 -ss 00:00:00 -t  00:00:06 -c copy  -strict -2 output.mp4
# ffmpeg -i input.mp4 -vf scale=-1:240 -r 10  -loop 0  -y output.webp
#get one frame from webp
#  webpmux -get frame 1 Input.webp  -o Output.png
#*****************************************************************************


#*****************************************************************************
#   live stream to/from rtmp server
#*****************************************************************************
#live with ffmpeg to RTMP server
# take local video test_02.mp4 for example

# --push video stream to live server
ffmpeg -re -i test_02.mp4  -c copy -f flv rtmp://push1.arenazb.hupu.com/test/sld

# --pull live  stream from rtmp server and save to local disk at the same time
ffmpeg -i  rtmp://push1.arenazb.hupu.com/test/sld -c copy test_02_dump.mp4

#ffplay for rtmp server
ffplay rtmp://push1.arenazb.hupu.com/test/sld

#there sha1 string for test_02_dump.mp4 test_02.mp4 are the same
#*****************************************************************************


#*****************************************************************************
#    264 stream to mp4 format files
#*****************************************************************************
ffmpeg -framerate 24 -i input.264 -c copy output.mp4
ffmpeg -i Zhling_1280x720.264 -c copy Zhling_1280x720.264_only.mp4

#*****************************************************************************


#*****************************************************************************
#   extract 264 stream for mp4 files
#*****************************************************************************
# --YUV tool
# --264 bitstream analyse: encoder parameters
# --bit stream size, quality

ffmpeg -i ${VideoDouYin} -vbsf h264_mp4toannexb -vcodec copy  -f h264  ${BitStreamDouYin}
ffmpeg -i Zhling_1280x720.264_only.mp4 -vbsf h264_mp4toannexb -vcodec copy  -f h264  Zhling_1280x720.264_only.mp4.264

#YUV comparision
./JMDecoder -p "InputFile=Zhling_1280x720.264" -p "OutputFile=Zhling_1280x720.264_origin.yuv"
./JMDecoder -p "InputFile=Zhling_1280x720.264_only.mp4.264" -p "OutputFile=Zhling_1280x720.264_only.mp4.264.yuv"

#Zhling_1280x720.264_only.mp4

#
#
#*****************************************************************************


#*****************************************************************************
#  file format covertion
#*****************************************************************************
#
# reference: https://www.labnol.org/internet/useful-ffmpeg-commands/28490/
#
#*****************************************************************************



#Douyin cache dir
/sdcard/Android/data/com.ss.android.ugc.aweme/cache/video/cache

adb pull -a /sdcard/Android/data/com.ss.android.ugc.aweme/cache/video/cache/  DouYinCache/

#Muse cache dir
/sdcard/Android/data/com.zhiliaoapp.musically/files/videos


# Extract audio
#  http://blog.csdn.net/xiaocao9903/article/details/53420519
ffmpeg -i 3.mp4 -vn -y -acodec copy 3.aac
ffmpeg -i 3.mp4 -vn -y -acodec copy 3.m4a


#mix audio and video to mp4 file
ffmpeg -i video2.avi -i audio.mp3 -vcodec copy -acodec copy output.avi

#*****************************************************************************
#  picture/image extract, cover extract
#*****************************************************************************

ffmpeg -i Input.mp4 -r:1 -q:v -f image2 OutputImage_%d.jpeg
#   -r:1  1 picture per one second
#   -q:v  output picture quality

#*****************************************************************************







