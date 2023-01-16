#!/bin/env bash
#SBATCH --partition=rimlsfnwi
#SBATCH --job-name=scifi_join
#SBATCH --output=./log/%x-%A-%a.out
#SBATCH --error=./log/%x-%A-%a.err
#SBATCH --time=08:00:00
#SBATCH --mem 8G
#SBATCH -c 1

wd=/ceph/rimlsfnwi/data/cellbio/mhlanga/thsieh/
sub=scifi
filtered=$wd/$sub/filtered
exp1=scifi#40532_Day1_Musa_scifi3_N703
exp2=scifi#40533_Day1_Musa_scifi2_N702
outputDir=$wd/$sub/joined

for exp in $exp1 $exp2
do 
	if [ -d "$filtered/$exp" ]; then
        	echo "$exp exists"
        	rm  -r $filtered/$exp
	fi
done

for exp in $exp1 $exp2
do 
        if [ -f " $outputDir/$exp.metrics.csv.gz" ]; then
                echo "$outputDir/$exp.metrics.csv.gz exists"
                rm $outputDir/$exp.metrics.csv.gz
        fi
done

for exp in $exp1 $exp2
do
	mkdir $filtered/$exp

	scp $filtered/$exp*/*metrics_corrected.csv.gz $filtered/$exp
	find $filtered/$exp -mindepth 1 -name '*metrics_corrected.csv.gz' -exec cat {} \; > $outputDir/$exp.metrics.csv.gz
    		echo 'r2,read,unique_umi,umi,gene,unique_fraction,sample_name' > $exp.header
    		gzip $exp.header
    		cat $exp.header.gz $outputDir/$exp.metrics.csv.gz > $exp.tmp
    		mv $exp.tmp $outputDir/$exp.metrics.csv.gz
    		rm $exp.header.gz
	scp $filtered/$exp*/*expression_corrected.csv.gz $filtered/$exp
	find $filtered/$exp -mindepth 1 -name '*expression_corrected.csv.gz' -exec cat {} \; > $outputDir/$exp.expression.csv.gz
		echo '['r2', 'gene', 'umi', 'sample_name']' > $exp.2.header
		gzip $exp.2.header
		cat $exp.2.header.gz $outputDir/$exp.expression.csv.gz > $exp.tmp2
		mv $exp.tmp2 $outputDir/$exp.expression.csv.gz
		rm $exp.header.2.gz

done
