#!/bin/bash


runUsage()
{
    echo "**********************************************"
    echo " $0  \$MP4FilesDir \$Option                   "
    echo "     example:                                 "
    echo "     $0  ./AllMP4 All                         "
    echo "         single report for all mp4files       "
    echo "     $0  ./AllMP4 MuseDouyin                  "
    echo "         report for Muse and douyin           "
    echo "**********************************************"
}

runInit()
{
    DetailStaticFile="StaticInfoDetail.csv"
    SequenceStaticFile="StaticInfoForAllSequences.csv"
    FrameStatiFile="StaticInfoForAllFrames.csv"


    PatternDouyin="Douyin.mp4"
    PatternMuse="Muse.mp4"

    Prefix=`echo $DetailStaticFile | awk 'BEGIN {FS="."} {print $1}'`
    StaticDetailDouyin="${Prefix}_${PatternDouyin}.csv"
    StaticDetailMuse="${Prefix}_${PatternMuse}.csv"

    EncParamAvgFile="EncoderParametersAverage.csv"
    Prefix=`echo $EncParamAvgFile | awk 'BEGIN {FS="."} {print $1}'`
    EncParamAvgTableDouyin="${Prefix}_Douyin.csv"
    EncParamAvgTableMuse="${Prefix}_Muse.csv"

    DouYinMuseComparison="StaticCombine2CSVfiles.csv"
}

runParseStreamEyeCSV()
{
    ./run_ParseStreamEyeCSVFiles.sh ${MP4FilesDir}
    if [ ! $? -eq 0 ]
    then
        echo "failed!--runParseStreamEyeCSV"
        exit 1
    fi
}

runGenerateDouyinAndMuseCSVFile()
{
    ./run_FileEditorForCSV.sh ${DetailStaticFile} "Filter" "${PatternDouyin}"
    if [ ! $? -eq 0 ]
    then
        echo "failed!--runGenerateDouyinAndMuseCSVFile Filter Douyin"
        exit 1
    fi

    ./run_FileEditorForCSV.sh ${DetailStaticFile} "Filter" "${StaticDetailMuse}"
    if [ ! $? -eq 0 ]
    then
        echo "failed!--runGenerateDouyinAndMuseCSVFile Filter Muse"
        exit 1
    fi

    #Douyin
    ./run_CalculateAverage.sh ${StaticDetailDouyin}
    if [ ! $? -eq 0 ]
    then
        echo "failed!--runGenerateDouyinAndMuseCSVFile Calcul average Douyin"
        exit 1
    fi
    mv ${EncParamAvgFile} ${EncParamAvgTableDouyin}

    #Muse
    ./run_CalculateAverage.sh ${StaticDetailMuse}
    if [ ! $? -eq 0 ]
    then
        echo "failed!--runGenerateDouyinAndMuseCSVFile Calcul average Muse"
        exit 1
    fi
    mv ${EncParamAvgFile} ${EncParamAvgTableMuse}

    #generate final comparison table
    ./run_FileEditorForCSV.sh ${EncParamAvgTableDouyin} "Combine" ${EncParamAvgTableMuse}
    if [ ! $? -eq 0 ]
    then
        echo "failed!--runGenerateDouyinAndMuseCSVFile Combine for Douyin and Muse"
        exit 1
    fi
}

runGenerateForAll()
{
    ./run_CalculateAverage.sh ${DetailStaticFile}
    if [ ! $? -eq 0 ]
    then
        echo "failed!--runGenerateForAll"
        exit 1
    fi
}

runOutputForAll()
{
    echo "********************************************"
    echo "********************************************"
    echo "    Final report for all                    "
    echo "    MP4 dir is $MP4FilesDir                 "
    echo "********************************************"
    echo "    Static csv files list:                  "
    echo "********************************************"
    echo "    DetailStaticFile:   $DetailStaticFile   "
    echo "    SequenceStaticFile: $SequenceStaticFile "
    echo "    FrameStatiFile:     $FrameStatiFile     "
    echo "********************************************"
    echo "   Encoder paramters average static table   "
    echo "   EncParamAvgFile:     $EncParamAvgFile    "
    echo "********************************************"
    echo "********************************************"
}

runOutputForDouyinAndMuse()
{
    echo "********************************************"
    echo "********************************************"
    echo "    Final report for all                    "
    echo "    MP4 dir is $MP4FilesDir                 "
    echo "********************************************"
    echo "    Static csv files list:                  "
    echo "********************************************"
    echo "    DetailStaticFile:   $DetailStaticFile   "
    echo "    SequenceStaticFile: $SequenceStaticFile "
    echo "    FrameStatiFile:     $FrameStatiFile     "
    echo "********************************************"
    echo "   Encoder paramters average static table   "
    echo "********************************************"
    echo "       Douyin: $EncParamAvgTableDouyin      "
    echo "       Muse:   $EncParamAvgTableMuse        "
    echo "       All:    $DouYinMuseComparison        "
    echo "********************************************"
    echo "********************************************"
}

runCheck()
{
    echo "**************************************************"
    echo " Checking input parameters..."
    echo " MP4FilesDir is ${MP4FilesDir}"
    echo "**************************************************"

    if [ ! -d ${MP4FilesDir} ]
    then
        echo "MP4FilesDir does not exist, please double check!"
        exit 1
    fi

    Flag="true"
    [[ "$Option" =~ "All" ]] || [[ "$Option" =~ "MuseDouyin" ]] || Flag="false"
    if [[ "${Flag}" =~ "false" ]]
    then
        echo "**********************************************"
        echo " option should be: All or MuseDouyin         "
        echo "**********************************************"
        exit 1
    fi
}


runMain()
{
    runInit
    runCheck

    if [[ "$Option" =~ "All" ]]
    then
        runParseStreamEyeCSV
        runGenerateForAll
        runOutputForAll
    elif [[ "$Option" =~ "MuseDouyin" ]]
    then
        runParseStreamEyeCSV
        runGenerateDouyinAndMuseCSVFile
        runOutputForDouyinAndMuse
    fi
}

#**********************************************************
#**********************************************************
if [ $# -lt 2 ]
then
    runUsage
    exit 1
fi

MP4FilesDir=$1
Option=$2

runMain
