#!/bin/bash


runUsage()
{
echo "**********************************************"
echo "**********************************************"


}


runInit()
{

    OutputFile=""


}


runCheck()
{
    if [ ! -e ${InputCSVFile} ]
    then
        echo "  InputCSVFile ${InputCSVFile} does not exist, please double check!"
        exit 1
    fi


}


runFilter()
{
    let "HeadderNum = 2"
    let "LineNum =0"
    FilterPattern="OptionVal"
    CSVFileName=`echo $InputCSVFile | awk 'BEGIN {FS=","} {print $1}'`
    OutputFile="${OutputFile}_${FilterPattern}.csv"

    echo "**********************************************"
    echo "  InputCSVFile  is: ${InputCSVFile}"
    echo "  FilterPattern is: ${FilterPattern}"
    echo "  OutputFile    is: ${OutputFile}"
    echo "**********************************************"

    while read line
    do
        [ ${LineNum} -eq 0 } ] && echo "$line" >${OutputFile}
        [ ${LineNum} -lt ${HeadderNum} ] && echo "$line" >>${OutputFile}

        [[ "${line}" =~ "${FilterPattern}" ]] && echo "$line" >>${OutputFile}

        let "LineNum ++"
    done

    if [  ${LineNum} -le ${HeadderNum} ]
    then
        echo "**********************************************"
        echo " no data matched ${FilterPattern}"
        echo "**********************************************"

    fi
}

runMain()
{

runInit
runCheck
runFilter

}


#***************************
if [ $# -lt 3 ]
then
    runUsage
    exit 1
fi

InputCSVFile=$1
Option=$2
OptionVal=$3

runMain

