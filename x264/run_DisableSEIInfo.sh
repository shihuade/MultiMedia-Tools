#!/bin/bash
#***************************************************************
# brief:
#       disable x264 encoder parameters' SEI Nal
#       with build and validation
#
#***************************************************************

runUsage()
{
    echo -e "\033[31m ***************************************** \033[0m"
    echo "     Usage:                                                  "
    echo "          $0  \$x264dir                                      "
    echo "                                                             "
    echo -e "\033[31m ***************************************** \033[0m"
}

runInit()
{
    SEISourceFile="encoder/encoder.c"
    SEIFunction="x264_sei_version_write"
    x264Bin="${x264Dir}/x264"
    x264Lib="${x264Dir}/libx264.a"

    #for x264 build setting
    Config="configure"
    PresetForBuild=""

    #veridate setting
    InputYUV="../../../YUV/BasketballDrill_832x480_50.yuv"
    OutputBitStream="x264NoSEIInfoTest.264"
}

runCheck()
{
    if [ ! -d ${x264Dir} ]
    then
        echo "Input x264 dir doest not exist, please double check"
        runUsage
        exit 1
    fi
}

runDisableEncParamSEI()
{
    cd ${x264Dir}

    #get repos info
    #****************************************************
    git checkout ${SEISourceFile}
    git branch
    git remote -v
    git log -2

    #disable SEI
    #****************************************************
    #delete below line in source file
    #    if( x264_sei_version_write( h, &h->out.bs ) )
    #        return -1;
    #****************************************************

    #get line number and delete it
    LineNum=`cat ${SEISourceFile} | egrep -n "${SEIFunction}" | awk 'BEGIN {FS=":"} {print $1}'`
    aLineNum=(${LineNum})

    for linenum in ${aLineNum[@]}
    do
SedCommand="sed -i \".bak\" \"${linenum}d\" ${SEISourceFile}"
echo "command is: ${SedCommand}"

sed -i ".bak" "${linenum}d" ${SEISourceFile}

SedCommand="sed -i \".bak\" \"${linenum}d\" ${SEISourceFile}"
echo "command is: ${SedCommand}"
sed -i ".bak" "${linenum}d" ${SEISourceFile}
    done

    #remove .bak files
    rm ${SEISourceFile}*.bak

    cd -
}

runCheckDisableStatus()
{
    cd ${x264Dir}

    echo -e "\033[32m ***************************************** \033[0m"
    echo    "   checking disable status                                "
    echo -e "\033[32m ***************************************** \033[0m"

    git diff ./*
    cd -
}

runBuildx264WithoutEncParamSEI()
{

    cd ${x264Dir}

    echo -e "\033[32m ***************************************** \033[0m"
    echo    "   start to build x264 without encparam SEI               "
    echo -e "\033[32m ***************************************** \033[0m"

    #if incremental build, no need to git clean
    git clean -fdx

    #config for build
    ./${Config} ${PresetForBuild}
    [ $? -ne 0 ] && echo -e "\033[31m preset for build failed! \033[0m" && exit 1

    make
    cd -

    [ -e ${x264Bin} ] || [ -e ${x264Lib} ] || Flag="Failed"
    [ "$Flag" = "Failed" ] && echo -e "\033[31m x264 bin or lib not found! \033[0m" && exit 1

    echo -e "\033[32m ***************************************** \033[0m"
    echo -e "\033[33m  x264 without encParam build passed!      \033[0m"
    echo -e "\033[32m ***************************************** \033[0m"

}

runValidate()
{
    cp ${x264Bin} ./
    cp ${x264Lib} ./


    ./x264 -o ${OutputBitStream}  ${InputYUV}
    [ $? -ne 0 ] && echo -e "\033[31m x264 encoding failed! \033[0m" && exit 1

    echo -e "\033[32m ***************************************** \033[0m"
    echo -e "\033[33m  x264 encoding validate passed!           \033[0m"
    echo -e "\033[32m ***************************************** \033[0m"
}

runPrompt()
{
    echo -e "\033[32m ***************************************** \033[0m"
    echo -e "\033[33m  summary:                                 \033[0m"
    echo -e "\033[33m      x264 disable enc param SEI info      \033[0m"
    echo -e "\033[32m ***************************************** \033[0m"
    echo -e "\033[33m                                           \033[0m"
    echo -e "\033[33m   x264 bin: ${x264Bin}                    \033[0m"
    echo -e "\033[33m   x264 lib: ${x264Lib}                    \033[0m"
    echo -e "\033[32m ***************************************** \033[0m"
    echo -e "\033[33m  validate file: ${OutputBitStream}        \033[0m"
    echo -e "\033[32m ***************************************** \033[0m"
}

runMain()
{
    runCheck

    runInit

    runDisableEncParamSEI
    runCheckDisableStatus

    runBuildx264WithoutEncParamSEI
    runValidate

    runPrompt
}

#*************************************************************

if [ $# -lt 1 ]
then
    runUsage
    exit 1
fi


x264Dir=$1
runMain

#*************************************************************




