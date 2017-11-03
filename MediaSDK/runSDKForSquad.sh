#!/bin/bash





#****************************************
#ijkplayer ffmpeg build
#****************************************
sh init-android.sh

cd android
sh build_ijkplayer.sh armv7a lively

# copy to Squad
cp   android/contrib/build/ffmpeg-armv7a/output/shared/lib/libijkffmpeg.so
to  Squad/common/src/main/jniLibs/armeabi-v7a/
#****************************************



#****************************************
#ijkplayer SDK build
#****************************************
step 1:
cd ijkplayer
sh init-android.sh

step 2:
cd android/contrib
sh compile-libwebp.sh
sh compile-openssl.sh
sh compile-x264.sh

sh compile-ffmpeg-xxx.sh

step3:
cd ..
sh compile-ijk.sh
#****************************************


#****************************************
#MediaStreamer SDK build
#****************************************
sh init-android.sh

# build for lively
cd android/MediaStreamer/
sh compile_native_library.sh l

#copy to Squad
cp ./android/MediaStreamer/library/src/main/obj/local/armeabi-v7a/libMediaStreamer.so
to  Squad/common/src/main/jniLibs/armeabi-v7a/
#****************************************















