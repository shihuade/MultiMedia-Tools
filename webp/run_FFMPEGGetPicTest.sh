
#!/bin/bash

runInit()
{
    MP4File="./Test.mp4"
    StartTime="00:00:01"
QP="80"
OutputImage01="./${MP4File}_01_QP_${QP}.jpeg"
OutputImage02="${MP4File}_02_QP_${QP}.jpeg"

#Command01="ffmpeg -i ${MP4File} -f image2 -ss ${StartTime} -q 8 -vframes 1 ${OutputImage01} -y"
#Command02="ffmpeg -ss ${StartTime} -i ${MP4File}  -f image2 -q 8 -vframes 1 ${OutputImage02} -y"
Command01="ffmpeg -i ${MP4File} -ss 0.1  -an -qscale ${QP} -vframes 1 -f image2  -y ${OutputImage01}"
Command02="ffmpeg -ss 0.1 -i ${MP4File} -an -qscale ${QP} -vframes 1 -f image2  -y ${OutputImage02}"

}

runTest01()
{
    for ((i=0; i<1;i++))
    do
${Command01}
    done
}

runTest02()
{
for ((i=0; i<1;i++))
do
${Command02}
done
}


runMain()
{
runInit
echo "Command01 is ${Command01}"
StartTime01=`date`
runTest01
EndTime01=`date`

echo "Command02 is ${Command02}"
StartTime02=`date`
runTest02
EndTime02=`date`

echo "******************************************"
echo "******************************************"
echo " Command01   is $Command01"
echo " StartTime01 is $StartTime01"
echo " EndTime01   is $EndTime01"
echo "******************************************"
echo " Command02   is $Command02"
echo " StartTime02 is $StartTime02"
echo " EndTime02   is $EndTime02"
echo "******************************************"
echo "******************************************"
}

runMain


