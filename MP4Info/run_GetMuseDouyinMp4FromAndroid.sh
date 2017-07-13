#!/bin/bash
#***************************************************
# download mp4 files from android device
#***************************************************

runUsage()
{
    echo "**********************************************************"
    echo "**********************************************************"
    echo "  Usage:                                                  "
    echo "     $0  \${Option}                                       "
    echo "                                                          "
    echo "          example:                                        "
    echo "             Douyin download all douyin files "
    echo "             Muse   download all muse's files "
    echo "             no option, both muse and douyin              "
    echo "                   parse all douyin's/muse's  mp4 files   "
    echo ""
    echo "**********************************************************"
    echo "**********************************************************"
}

runInit()
{
    #Douyin cache dir
    DouYinCacheDir="/sdcard/Android/data/com.ss.android.ugc.aweme/cache/video/cache"
    DouYinDestDir="DouYinCache"
    DouYinStreamDir="${DouYinDestDir}/cache"

    #Muse cache dir
    MuseCacheDir="/sdcard/Android/data/com.zhiliaoapp.musically/files/videos"
    MuseDestDir="MuseCache"
    MuseStreamDir="${MuseDestDir}/videos"

    #remove previous data
    [ -d ${DouYinDestDir} ] && rm -rf ${DouYinDestDir}
    [ -d ${MuseDestDir} ]   && rm -rf ${MuseDestDir}

    #create new dest dir
    mkdir ${DouYinDestDir}
    mkdir ${MuseDestDir}
}

runPullFromAndroid_Douyin()
{

    #pull and extract from douyin cache
    Command="adb pull -a ${DouYinCacheDir} ${DouYinDestDir}"
    echo "**********************************************"
    echo "Start to pull from douyin"
    echo "Command is:"
    echo " ${Command}"
    echo "**********************************************"
    ${Command}
    [ ! $? -eq 0 ] && exit 1

}

runPullFromAndroid_Muse()
{
    #pull and extract from muse cache
    Command="adb pull -a ${MuseCacheDir} ${MuseDestDir}"
    echo "**********************************************"
    echo "Start to pull from muse"
    echo "Command is:"
    echo " ${Command}"
    echo "**********************************************"
    ${Command}
    [ ! $? -eq 0 ] && exit 1
}

runMain()
{
    runInit

    if [ ! -z "${Option}" ]
    then
        [[ "${Option}" =~ "Muse" ]]   && runPullFromAndroid_Muse
        [[ "${Option}" =~ "Douyin" ]] && runPullFromAndroid_Douyin
    else
        runPullFromAndroid_Muse
        runPullFromAndroid_Douyin
    fi
}

#************************************************

Option=$1

runUsage
runMain


