if [ "$1" != "" ]; then
    for run in {1..10}
    do
        ./iris_tensorflow.exe iris_man_unrolled_no_printfs.cl  -g $1 2>&1 | awk -F , 'NF == 18'
    done
else
    for run in {1..10}
    do
        ./iris_tensorflow.exe iris_man_unrolled_no_printfs.cl 2>&1 | awk -F , 'NF == 18'
    done
fi 
