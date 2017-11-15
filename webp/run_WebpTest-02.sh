#!/bin/bash


InputWebp=$1
OutputWebp01="${InputWebp}_forward.webp"
OutputWebp02="${InputWebp}_backward.webp"


for((i=0; i<10; i++))
do
webpmux -get frame $i ${InputWebp} -o ${InputWebp}_$i.webp
done

Command=""
for((i=0; i<5;i++))
do
Command="${Command} -frame ${InputWebp}_$i.webp +500"
done

Command="webpmux ${Command} -loop 0 -bgcolor 255,255,255,255 -o ${OutputWebp01}"
echo "******************"
echo "Command is $Command"
echo "******************"
${Command}

Command=""
for((i=9; i>4;i--))
do
Command="${Command} -frame ${InputWebp}_$i.webp +500"
done

Command="webpmux ${Command} -loop 0 -bgcolor 255,255,255,255 -o ${OutputWebp02}"
echo "******************"
echo "Command is $Command"
echo "******************"
${Command}

