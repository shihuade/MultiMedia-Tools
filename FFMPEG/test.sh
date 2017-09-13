#/bin.sh


enable(){
    echo $*
    set_all yes $*
}


set_all(){
    value=$1
    shift
    for var in $*; do
        eval $var=$value

        echo "\$var   is $var"
        echo "\$value is $value"
    done
}



enable 1 2 3

