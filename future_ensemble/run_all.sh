#sleep 60m

parallel -j12 bash do_run.sh ::: {89..100}


#for i in {1..50}
#do
#    if [ $(( $i % 75 )) -eq 0 ]; then
#	echo "Number: $i"
#	sleep 30m
#    fi
    
#    echo "Number: $i"
#    bash do_run.sh $i
#    sleep 5s
#done
