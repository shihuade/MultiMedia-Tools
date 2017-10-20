#!/bin/bash

#********************************************************************************
#  libYUV
#  https://github.com/shihuade/libyuv.git
#********************************************************************************
#    ./convert [-options] src_argb.raw dst_yuv.raw
#    -s <width> <height> .... specify source resolution.  Optional if name contains
#                             resolution (ie. name.1920x800_24Hz_P420.yuv)
#                             Negative value mirrors.
#    -d <width> <height> .... specify destination resolution.
#    -f <filter> ............ 0 = point, 1 = bilinear (default).
#    -skip <src_argb> ....... Number of frame to skip of src_argb
#    -frames <num> .......... Number of frames to convert
#    -attenuate ............. Attenuate the ARGB image
#    -unattenuate ........... Unattenuate the ARGB image
#    -v ..................... verbose
#    -h ..................... this help
#********************************************************************************

./convert -s 1920 1080 -d 848 480 ../../../YUV/BasketballDrive_1920x1080_50.yuv   ~/Desktop/BasketballDrive_1920x1080_50.yuv_848x480.yuv

./convert ../../../YUV/BasketballDrive_1920x1080_50.yuv   ~/Desktop/BasketballDrive_1920x1080_50.yuv_848x480.yuv

#********************************************************************************
#   https://github.com/shihuade/yuvconverter.git
#********************************************************************************
#    +------------------------------------------------------------+
#    |  Usage: <infile> <outfile> <width> <height> <conv_code>    |
#    +------------------------------------------------------------+
#    |      Input Format      |    Output Format       | ConvCode |
#    +------------------------------------------------------------+
#    |   YUV420 Prog Planar   |   YUV420 Int Planar    |  110111  |
#    |   YUV420 Prog Planar   |   YVU420 Prog Planar   |  110120  |
#    |   YUV420 Prog Planar   |   YVU420 Int Planar    |  110121  |
#    |   YUV420 Prog Planar   |   YCbCr Prog Planar    |  110130  |
#    +------------------------------------------------------------+
#    |   YUV420 Prog Planar   |   YUV422 Prog Planar   |  110210  |
#    |   YUV420 Prog Planar   |   YUV422 Int Planar    |  110211  |
#    |   YUV420 Prog Planar   |   YVU422 Prog Planar   |  110220  |
#    |   YUV420 Prog Planar   |   YVU422 Int Planar    |  110221  |
#    +------------------------------------------------------------+
#    |   YUV420 Prog Planar   |   UYVY Prog            |  110230  |
#    |   YUV420 Prog Planar   |   UYVY Int             |  110231  |
#    |   YUV420 Prog Planar   |   YUYV Prog            |  110240  |
#    |   YUV420 Prog Planar   |   YUYV Int             |  110241  |
#    |   YUV420 Prog Planar   |   YVYU Prog            |  110250  |
#    |   YUV420 Prog Planar   |   YVYU Int             |  110251  |
#    +------------------------------------------------------------+
#    |   YUV420 Prog Planar   |   YUV444 Prog Planar   |  110310  |
#    |   YUV420 Prog Planar   |   YUV444 Int Planar    |  110311  |
#    |   YUV420 Prog Planar   |   YVU444 Prog Planar   |  110320  |
#    |   YUV420 Prog Planar   |   YVU444 Int Planar    |  110321  |
#    |   YUV420 Prog Planar   |   UYV444 Prog Planar   |  110330  |
#    |   YUV420 Prog Planar   |   UYV444 Int Planar    |  110331  |
#    +------------------------------------------------------------+
#    |   YUV420 Prog Planar   |   YUV444 Prog Packed   |  110340  |
#    |   YUV420 Prog Planar   |   YUV444 Int Packed    |  110341  |
#    |   YUV420 Prog Planar   |   YVU444 Prog Packed   |  110350  |
#    |   YUV420 Prog Planar   |   YVU444 Int Packed    |  110351  |
#    |   YUV420 Prog Planar   |   UYV444 Prog Packed   |  110360  |
#    |   YUV420 Prog Planar   |   UYV444 Int Packed    |  110361  |
#    +------------------------------------------------------------+
#    |   YUV420 Prog Planar   |   RGB Prog Planar      |  110410  |
#    |   YUV420 Prog Planar   |   BGR Prog Planar      |  110420  |
#    |   YUV420 Prog Planar   |   RGB Prog Packed      |  110430  |
#    |   YUV420 Prog Planar   |   BGR Prog Packed      |  110440  |
#    +------------------------------------------------------------+
#    |                                                            |
#    +------------------------------------------------------------+
#    |   YUV420 Int Planar    |   YUV420 Prog Planar   |  111110  |
#    |   YVU420 Prog Planar   |   YUV420 Prog Planar   |  120110  |
#    |   YVU420 Int Planar    |   YUV420 Prog Planar   |  121110  |
#    |   YCbCr Prog Planar    |   YUV420 Prog Planar   |  130110  |
#    +------------------------------------------------------------+
#    |   YUV422 Prog Planar   |   YUV420 Prog Planar   |  210110  |
#    |   YUV422 Int Planar    |   YUV420 Prog Planar   |  211110  |
#    |   YVU422 Prog Planar   |   YUV420 Prog Planar   |  220110  |
#    |   YVU422 Int Planar    |   YUV420 Prog Planar   |  221110  |
#    +------------------------------------------------------------+
#    |   UYVY Prog            |   YUV420 Prog Planar   |  230110  |
#    |   UYVY Int             |   YUV420 Prog Planar   |  231110  |
#    |   YUYV Prog            |   YUV420 Prog Planar   |  240110  |
#    |   YUYV Int             |   YUV420 Prog Planar   |  241110  |
#    |   YVYU Prog            |   YUV420 Prog Planar   |  250110  |
#    |   YVYU Int             |   YUV420 Prog Planar   |  251110  |
#    +------------------------------------------------------------+
#    |   YUV444 Prog Planar   |   YUV420 Prog Planar   |  310110  |
#    |   YUV444 Int Planar    |   YUV420 Prog Planar   |  311110  |
#    |   YVU444 Prog Planar   |   YUV420 Prog Planar   |  320110  |
#    |   YVU444 Int Planar    |   YUV420 Prog Planar   |  321110  |
#    |   UYV444 Prog Planar   |   YUV420 Prog Planar   |  330110  |
#    |   UYV444 Int Planar    |   YUV420 Prog Planar   |  331110  |
#    +------------------------------------------------------------+
#    |   YUV444 Prog Packed   |   YUV420 Prog Planar   |  340110  |
#    |   YUV444 Int Packed    |   YUV420 Prog Planar   |  341110  |
#    |   YVU444 Prog Packed   |   YUV420 Prog Planar   |  350110  |
#    |   YVU444 Int Packed    |   YUV420 Prog Planar   |  351110  |
#    |   UYV444 Prog Packed   |   YUV420 Prog Planar   |  360110  |
#    |   UYV444 Int Packed    |   YUV420 Prog Planar   |  361110  |
#    +------------------------------------------------------------+
#    |   RGB Prog Planar      |   YUV420 Prog Planar   |  410110  |
#    |   BGR Prog Planar      |   YUV420 Prog Planar   |  420110  |
#    |   RGB Prog Packed      |   YUV420 Prog Planar   |  430110  |
#    |   BGR Prog Packed      |   YUV420 Prog Planar   |  440110  |
#    +------------------------------------------------------------+
#********************************************************************************

../../../YUV/BasketballDrive_1920x1080_50.yuv ~/Desktop/BasketballDrive_1920x1080_50.yuv.rgb 1920 1080 110410








