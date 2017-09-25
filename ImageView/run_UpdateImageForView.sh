#!/bin/bash
#********************************************************************************
#  copy image from given dir, and preparing for comarision
#
#     ViewModule/index.html will browse image from
#     ViewModule/images
#
#********************************************************************************

runUsage()
{
    echo -e "\033[31m ***************************************************** \033[0m"
    echo "   Usage:                                                       "
    echo "      $0  \$ImageDir \${Pattern01} \${Pattern02}                "
    echo "      --ImageDir:  image files which will be view via browser   "
    echo "      --Pattern0X: image file patern for filtering              "
    echo -e "\033[31m ***************************************************** \033[0m"
}

runInit()
{
    CurrentDir=`pwd`
    ImageDirForView="${CurrentDir}/ViewModule/images"

    [ -d ${ImageDirForView} ] && rm -rf ${ImageDirForView}
    mkdir -p ${ImageDirForView}
}

runCheck()
{
    if [ ! -d ${ImageDir} ]
    then
        echo "Image dir not exist, please double check"
        runUsage
        exit 1
    fi
}

runPromtForOneImage()
{
    echo -e "\033[32m ******************************* \033[0m"
    echo -e "\033[32m   Index     is: ${Index}        \033[0m"
    echo -e "\033[32m   ImageName is: ${ImageName}    \033[0m"
    echo -e "\033[32m ********************************\033[0m"

}

runPromt()
{
    echo -e "\033[32m ******************************************\033[0m"
    echo -e "\033[32m ImageDir        is: ${ImageDir}           \033[0m"
    echo -e "\033[32m ImageDirForView is: ${ImageDirForView}    \033[0m"
    echo -e "\033[32m Pattern1        is: ${Pattern1}           \033[0m"
    echo -e "\033[32m Pattern2        is: ${Pattern2}           \033[0m"
    echo -e "\033[32m ******************************************\033[0m"
}

runPrepareForImageVidew()
{
    let "Index = 0"
    for image in ${ImageDir}/*.jpeg
    do
        ImageName=`basename ${image}`

        MatchFlag="true"
        MatchFlag01=`echo ${ImageName} | grep ${Pattern1}`
        MatchFlag02=`echo ${ImageName} | grep ${Pattern2}`

        [ -z ${MatchFlag01} ] && [ -z ${MatchFlag01} ] && MatchFlag="false"
        [ "$MatchFlag" = "false" ] && continue

        cp $image   ${ImageDirForView}/${Index}.jpeg
        cp $image   ${ImageDirForView}/${Index}-02.jpeg

        runPromtForOneImage

        let "Index += 1"
    done
}


runMain()
{
    runInit

    runCheck

    runPromt

    runPrepareForImageVidew

}

#*************************************************************************************
if [ $# -lt 1 ]
then
    runUsage
    exit 1
fi

ImageDir=$1
Pattern1=$2
Pattern2=$3

runMain
#*************************************************************************************

