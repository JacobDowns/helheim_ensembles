echo $0
echo $1
mkdir results/$1
cd results/$1
matlab -nodesktop -nodisplay -batch 'i='$1'; loadonly=0; run ../../do_run' > output.txt
echo "done"
#rm *.tar.gz
#rm *.toolkits
#rm *.queue
#rm *.bin
#rm *.txt
