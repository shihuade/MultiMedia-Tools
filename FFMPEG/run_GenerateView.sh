#!/bin/bash
#*************************************************************************
#  brief:
#       browser based comparison for two mp4 files
#       script generate comparison html files for all matched mp4 filse
#
#*************************************************************************

runUsage()
{
    echo -e "\033[31m ***************************************** \033[0m"
    echo " Usage:                                                "
    echo "      $0  \$Input \${Pattern}                          "
    echo "                                                       "
    echo "      --InputMP4:   origin mp4 for comparison          "
    echo "                                                       "
    echo "      --InputMP4Dir:  all mp4 for comparison           "
    echo "      --Pattern:    mp4 file name pattern              "
    echo "                                                       "
    echo -e "\033[31m ***************************************** \033[0m"
}

runInit()
{
    InputFileName=`basename ${InputFile}`
    InputDir=`dirname ${InputFile}`
    let "FileNum = 0"
    aMP4FileList=()

    HTMLTemplate2View="index.html_template_2view"
    HTMLTemplate3View="index.html_template_3view"
    HTMLFile=""
}

runGetFilesSet()
{
    for file in ${InputDir}/${InputFileName}*${FilterPattern}*
    do
        if [[ "$file" =~ .mp4$ ]]
        then
            aMP4FileList[${FileNum}]="${file}"
            echo "index ${FileNum}: ${aMP4FileList[${FileNum}]}"
            let "FileNum ++"
        fi
    done
}

runMapSuffix()
{
    if [ -z "$suffix01" ]
    then
        suffix01_name="_org"
        suffix01=""
        params01="origin"
    else
        suffix01_name="${suffix01}"
        params01="${suffix01}"
        suffix01="${suffix01}.mp4"
    fi

    if [ -z "$suffix02" ]
    then
        suffix02_name="_org"
        suffix02=""
        params02="origin"
    else
        suffix02_name="${suffix02}"
        params02="${suffix02}"
        suffix02="${suffix02}.mp4"
    fi

    if [ -z "$suffix03" ]
    then
        suffix03_name="_org"
        suffix03=""
        params03="origin"
    else
        suffix03_name="${suffix03}"
        params03="${suffix03}"
        suffix03="${suffix03}.mp4"
    fi
}

runHTMLForTwoView()
{
    for ((i=0; i<$FileNum; i++))
    do
        for ((j=0; j<$FileNum; j++))
        do
            [ $j -le $i ] && continue

            #generate suffix
            #********************************************
            suffix01=`echo ${aMP4FileList[$i]} | awk 'BEGIN {FS=".mp4"} {print $2}'`
            suffix02=`echo ${aMP4FileList[$j]} | awk 'BEGIN {FS=".mp4"} {print $2}'`

            runMapSuffix

            #generate html page for comparison view
            #********************************************
            HTMLFile="${InputDir}/${InputFileName}_${suffix01_name}_vs_${suffix02_name}.html"
            cp ${HTMLTemplate2View} ${HTMLFile}

            sed -i ".bak" "s/OriginFileName/${InputFileName}/g" ${HTMLFile}

            sed -i ".bak" "s/suffix01/${suffix01}/g"  ${HTMLFile}
            sed -i ".bak" "s/suffix02/${suffix02}/g"  ${HTMLFile}

            sed -i ".bak" "s/Param_01/${params01}/g"  ${HTMLFile}
            sed -i ".bak" "s/Param_02/${params02}/g"  ${HTMLFile}

            rm ${HTMLFile}.bak
        done
    done
}

runHTMLForThreeView()
{

    for ((i=0; i<$FileNum; i++))
    do
        for ((j=0; j<$FileNum; j++))
        do
            for ((k=0; k<$FileNum; k++))
            do

                [ $j -le $i ] && continue
                [ $k -le $j ] && continue

                #generate suffix
                #********************************************
                suffix01=`echo ${aMP4FileList[$i]} | awk 'BEGIN {FS=".mp4"} {print $2}'`
                suffix02=`echo ${aMP4FileList[$j]} | awk 'BEGIN {FS=".mp4"} {print $2}'`
                suffix03=`echo ${aMP4FileList[$k]} | awk 'BEGIN {FS=".mp4"} {print $2}'`

                runMapSuffix

                #generate html page for comparison view
                #********************************************
                HTMLFile="${InputDir}/${InputFileName}_${suffix01_name}_vs_${suffix02_name}_vs_${suffix03_name}.html"
                cp ${HTMLTemplate3View} ${HTMLFile}

                sed -i ".bak" "s/OriginFileName/${InputFileName}/g" ${HTMLFile}

                sed -i ".bak" "s/suffix01/${suffix01}/g"  ${HTMLFile}
                sed -i ".bak" "s/suffix02/${suffix02}/g"  ${HTMLFile}
                sed -i ".bak" "s/suffix03/${suffix03}/g"  ${HTMLFile}

                sed -i ".bak" "s/Param_01/${params01}/g"  ${HTMLFile}
                sed -i ".bak" "s/Param_02/${params02}/g"  ${HTMLFile}
                sed -i ".bak" "s/Param_03/${params03}/g"  ${HTMLFile}

                rm ${HTMLFile}.bak
            done
        done
    done
}

runCheck()
{

    [ ! -f ${InputFile} ] && [ ! -d ${InputFile} ] && Flag="false"

    if [ "${Flag}" = "false" ]
    then
        echo "Input dir or file doest not exist, please double check"
        runUsage
        exit 1
    fi
}

runViewForOneFile()
{

    runInit
    runGetFilesSet
    runHTMLForTwoView
}


runViewAllFiles()
{

    for mp4files in ${InputDir}/*.mp4
    do
       InputFile=$mp4files
       runViewForOneFile
    done
}

runMain()
{
    runCheck

    [ -f ${InputFile} ] && InputFile=$Input && runViewForOneFile
    [ -d ${InputFile} ] && InputDir=$Input  && runViewAllFiles
    # runHTMLForThreeView
}



#**************************************************************

if [ $# -lt 1 ]
then
    runUsage
    exit 1
fi


Input=$1
FilterPattern=$2
runMain

#**************************************************************





