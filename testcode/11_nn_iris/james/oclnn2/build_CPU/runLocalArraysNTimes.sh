if [ "$1" != "" ]; then
    for run in {1..10}
    do
        ./iris_tensorflow_local_buffers.exe iris_local_arrays.cl -g $1 2>&1 | awk -F , 'NF == 18'
    done
else
    for run in {1..10}
    do
        ./iris_tensorflow_local_buffers.exe iris_local_arrays.cl 2>&1 | awk -F , 'NF == 18'
    done
fi 
