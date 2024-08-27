#!/bin/bash

help_func(){
	echo -e 'This script can be executed for generating genomic data and training deep learning models for detecting selective sweeps. It calls stdpopsim for data generation and RAiSD-AI for model traning.\n'
	
	echo -e 'Data generation parameter description\n'
	
	echo -e '\t-I: an initial seed for simulation (int) (default: 1)'
	echo -e '\t-C: a specific catalog (str) (default: HomSap)'
	echo -e '\t-d: demographic model (str) (default: None)'
	echo -e '\t-c: a specific chromosome (str) (default: chr1)'
	echo -e '\t-g: a genetic map (str) (default: None)'
	echo -e '\t-l: the left coordinate of the chromosome (int) (default: 1000000)'
	echo -e '\t-r: the right coordinate of the chromosome (int) (default: 2000000)'
	echo -e '\t-p: a specific population (str) (default: pop_0)'
	echo -e '\t-P: population size (int), it is ineffective when indicating a specific demographic model (default: 100000)'
	echo -e '\t-s: the number of samples (int) (default: 50)'
	echo -e '\t-n: the number of populations/simulations (int) (default: 1)'
	echo -e '\t-S: selection coefficient (float) (default: 0.5)'
	echo -e '\t-t: the generation time of selective sweeps (int) (default: 1000)'
	echo -e '\t-f: the minimum frequency at the end (float) (default: 1)'
	echo -e '\t-a: scaling factor to accelerate simulation (int) (default: 1)'
	echo -e '\t-o: output path of simulation (str) (default: None)\n'
	
	echo -e '\nDeep_Catalog provides five optional modes for users by setting the option -m with 0, 1, 2, 3 or 4.\n'
	
	echo -e 'Required flag:'
	echo -e '\t-m: mode (int), 0) generating the deep learning model based on user-specified datasets, 1) testing a dataset using an already-existing training model, 2) generating and testing the deep learning model based on user-specified datasets, 3) scanning the whole genome using an already-existing training model, 4) generating the deep learning model based on user-specified datasets and scanning the data using the training model. (default: 3)\n'
	
	echo -e 'If -m in 0, 3:'
	echo -e '\t-N: a unique run ID that is used to name the output files of RAiSD-AI, i.e., the info file and the report(s) (str) (default: None)'
	echo -e '\t-W: window size (int) (default: 50)'
	echo -e '\t-T: specifies the data type. When generating images (PNG) -> 0: raw data in all channels (default), 1: raw data in one channel and pairwise snp distances in the other channels, 2: raw data in one channel and mu-var-scaled values in the other channels. When generating data in custom binary format -> 0: raw snp data and positions (default), 1: derived allele frequencies and positions. (int) (default: 0)'
	echo -e '\t-b: converts image data to a custom binary format (.snp). Only supported by the PyTorch implementation. 0: disable, 1: enable [PYTORCH-ONLY] (int) (default: 0)'
	echo -e '\t-A: a specific deep learning archtecture (str) (default: FAST-NN)'
	echo -e '\t-e: the number of epochs (int) (default: 10)'
	
	
	echo -e '\nIf -m in 1:'
	echo -e '\t-N: a unique run ID that is used to name the output files of RAiSD-AI, i.e., the info file and the report(s) (str) (default: None)'
	echo -e '\t-W: window size (int) (default: 50)'
	echo -e '\t-T: specifies the data type. When generating images (PNG) -> 0: raw data in all channels (default), 1: raw data in one channel and pairwise snp distances in the other channels, 2: raw data in one channel and mu-var-scaled values in the other channels. When generating data in custom binary format -> 0: raw snp data and positions (default), 1: derived allele frequencies and positions. (int) (default: 0)'
	echo -e '\t-b: converts image data to a custom binary format (.snp). Only supported by the PyTorch implementation. 0: disable, 1: enable [PYTORCH-ONLY] (int) (default: 0)'
	echo -e '\t-i: the path to an existing training model (str) (default: None)'
	
	echo -e '\nIf -m in 2:'
	echo -e '\t-H: specify if the catalog is haploid (0) or diploid (1) (int) (default: 1)'
	echo -e '\t-L: provides the selection target (in basepairs) and calculates the average distance (over all datasets in the input file) between the selection target and the reported locations (int) (default: None)'
	echo -e '\t-D: provides a maximum distance from the selection target (in base pairs) to calculate success rates, i.e., reported locations in the proximity of the target of selection (provided via -T) (int) (default: 50)'
	echo -e '\t-G: grid size (int) (default: 10)'
	
	echo -e '\nIf -m in 4:'
	echo -e '\t-H: specify if the catalog is haploid (0) or diploid (1) (int) (default: 1)'
	echo -e '\t-L: provides the selection target (in basepairs) and calculates the average distance (over all datasets in the input file) between the selection target and the reported locations (int) (default: None)'
	echo -e '\t-D: provides a maximum distance from the selection target (in base pairs) to calculate success rates, i.e., reported locations in the proximity of the target of selection (provided via -T) (int) (default: 50)'
	echo -e '\t-G: grid size (int) (default: 10)'
	echo -e '\t-i: the path to an existing training model (str) (default: None)'
	
	exit 1
}



# Initialization

seed=1
catalog="HomSap"
haploid=1
demography="None"
chro="chr1"
genmap="None"
left=1000000
right=2000000
population="pop_0"
popsize=100000
numsam=50
numpop=1
selcoef=0.5
gentime=1000
minfre=1
scalingfactor=1
width=50
bin=0
typ=0
mode=3
epoch=10
arc="FAST-NN"
grid=10
distance=1000

while getopts "hI:C:H:d:c:g:l:r:p:P:s:n:T:S:t:f:a:W:b:N:e:b:A:i:m:G:D:L:o:" opt
do
	case "${opt}" in
		h) help_func;;
		I) seed=${OPTARG};;
		C) catalog=${OPTARG};;
		H) haploid=${OPTARG};;
		d) demography=${OPTARG};;
		c) chro=${OPTARG};;
		g) genmap=${OPTARG};;
		l) left=${OPTARG};;
		r) right=${OPTARG};;
		p) population=${OPTARG};;
		P) popsize=${OPTARG};;
		s) numsam=${OPTARG};;
		n) numpop=${OPTARG};;
		T) typ=${OPTARG};;
		S) selcoef=${OPTARG};;
		t) gentime=${OPTARG};;
		f) minfre=${OPTARG};;
		a) scalingfactor=${OPTARG};;
		W) width=${OPTARG};;
		b) bin=${OPTARG};;
		N) ID=${OPTARG};;
		e) epoch=${OPTARG};;
		b) bin=${OPTARG};;
		A) arc=${OPTARG};;
		i) input=${OPTARG};;
		m) mode=${OPTARG};;
		G) grid=${OPTARG};;
		D) distance=${OPTARG};;
		L) target=${OPTARG};;
		o) outpath=${OPTARG};;
	esac
done

length=$(($right - $left))
center=$(($length / 2))
testing=$(($numpop / 10))
scansam=$(($numsam * 2))
testseed=$(($seed + $numpop))




if [ "$mode" == "0" ]; then		# Training data generation and model training
	
	python Data_Generation.py -i $seed -C $catalog -d $demography -c $chro -g $genmap -l $left -r $right -p $population -P $popsize -s $numsam -n $numpop -m neutral -a $scalingfactor -o "$outpath"/RAW/NEUTRAL

	python Data_Generation.py -i $seed -C $catalog -d $demography -c $chro -g $genmap -l $left -r $right -p $population -P $popsize -s $numsam -n $numpop -m sweep -S $selcoef -t $gentime -f $minfre -a $scalingfactor -o "$outpath"/RAW/SWEEP


	if [ "$bin" == "0" ]; then
		./RAiSD-AI -op IMG-GEN -n "$ID"TrainingData -I "$outpath"/RAW/NEUTRAL/Simulations.txt -icl neutralTR -L $length -its $center -w $width -f -frm -typ $typ -O
		./RAiSD-AI -op IMG-GEN -n "$ID"TrainingData -I "$outpath"/RAW/SWEEP/Simulations.txt -icl sweepTR -L $length -its $center -w $width -f -typ $typ -O
		
	elif [ "$bin" == "1" ]; then
		./RAiSD-AI -op IMG-GEN -n "$ID"TrainingData -I "$outpath"/RAW/NEUTRAL/Simulations.txt -icl neutralTR -L $length -its $center -w $width -f -bin -frm -typ $typ -O 
		./RAiSD-AI -op IMG-GEN -n "$ID"TrainingData -I "$outpath"/RAW/SWEEP/Simulations.txt -icl sweepTR -L $length -its $center -w $width -f -bin -typ $typ -O
		
	else
		echo -e "Invalid input of -b"
		return 0;
	fi

	./RAiSD-AI -op MDL-GEN -n "$ID"Model -I RAiSD_Images."$ID"TrainingData -arc $arc -e $epoch -f -O
	


elif [ "$mode" == "1" ]; then	# Testing data generation and testing based on an already-trained model

	python Data_Generation.py -i $seed -C $catalog -d $demography -c $chro -g $genmap -l $left -r $right -p $population -P $popsize -s $numsam -n $numpop -m neutral -a $scalingfactor -o "$outpath"/RAW/NEUTRAL

	python Data_Generation.py -i $seed -C $catalog -d $demography -c $chro -g $genmap -l $left -r $right -p $population -P $popsize -s $numsam -n $numpop -m sweep -S $selcoef -t $gentime -f $minfre -a $scalingfactor -o "$outpath"/RAW/SWEEP
	
	if [ "$bin" == "0" ]; then
		./RAiSD-AI -op IMG-GEN -n "$ID"TestingData -I "$outpath"/RAW/NEUTRAL/Simulations.txt -icl neutralTE -L $length -its $center -w $width -f -frm -typ $typ -O
		./RAiSD-AI -op IMG-GEN -n "$ID"TestingData -I "$outpath"/RAW/SWEEP/Simulations.txt -icl sweepTE -L $length -its $center -w $width -f -typ $typ -O
		
	elif [ "$bin" == "1" ]; then
		./RAiSD-AI -op IMG-GEN -n "$ID"TestingData -I "$outpath"/RAW/NEUTRAL/Simulations.txt -icl neutralTE -L $length -its $center -w $width -f -bin -frm -typ $typ -O 
		./RAiSD-AI -op IMG-GEN -n "$ID"TestingData -I "$outpath"/RAW/SWEEP/Simulations.txt -icl sweepTE -L $length -its $center -w $width -f -bin -typ $typ -O
		
	else
		echo -e "Invalid input of -b"
		return 0;
	fi
	
	./RAiSD-AI -op MDL-TST -n "$ID"Result -mdl "$input" -f -I RAiSD_Images."$ID"TestingData -clp 2 sweepTR=sweepTE neutralTR=neutralTE
	
elif [ "$mode" == "2" ]; then	# Tesing data generation and scanning based on an already-trained model
	if [ "$haploid" == "0" ]; then
		python Data_Generation.py -i $seed -C $catalog -d $demography -c $chro -g $genmap -l $left -r $right -p $population -P $popsize -s $numsam -n $numpop -m sweep -S $selcoef -t $gentime -f $minfre -a $scalingfactor -o "$outpath"/RAW/SCAN
	
	elif [ "$haploid" == "1" ]; then
		python Data_Generation.py -i $seed -C $catalog -d $demography -c $chro -g $genmap -l $left -r $right -p $population -P $popsize -s $(($numsam * 2)) -n $numpop -m sweep -S $selcoef -t $gentime -f $minfre -a $scalingfactor -o "$outpath"/RAW/SCAN
		
	fi
	
	./RAiSD-AI -n FAST-NN-PT-BINFRQPOS-SCAN -mdl "$input" -f -op SWP-SCN -I "$outpath"/RAW/SCAN/Simulations.txt -L $length -frm -T $target -d $distance -G $grid -pci 1 1 -P -O

elif [ "$mode" == "3" ]; then	# Training & tesing data generation, training the model on training dataset and tesing on the trained model
	
	python Data_Generation.py -i $seed -C $catalog -d $demography -c $chro -g $genmap -l $left -r $right -p $population -P $popsize -s $numsam -n $numpop -m neutral -a $scalingfactor -o "$outpath"/RAW/TRAIN/NEUTRAL

	python Data_Generation.py -i $seed -C $catalog -d $demography -c $chro -g $genmap -l $left -r $right -p $population -P $popsize -s $numsam -n $numpop -m sweep -S $selcoef -t $gentime -f $minfre -a $scalingfactor -o "$outpath"/RAW/TRAIN/SWEEP
	
	python Data_Generation.py -i $testseed -C $catalog -d $demography -c $chro -g $genmap -l $left -r $right -p $population -P $popsize -s $numsam -n $testing -m neutral -a $scalingfactor -o "$outpath"/RAW/TEST/NEUTRAL

	python Data_Generation.py -i $testseed -C $catalog -d $demography -c $chro -g $genmap -l $left -r $right -p $population -P $popsize -s $numsam -n $testing -m sweep -S $selcoef -t $gentime -f $minfre -a $scalingfactor -o "$outpath"/RAW/TEST/SWEEP


	if [ "$bin" == "0" ]; then
		./RAiSD-AI -op IMG-GEN -n "$ID"TrainingData -I "$outpath"/RAW/TRAIN/NEUTRAL/Simulations.txt -icl neutralTR -L $length -its $center -w $width -f -frm -typ $typ -O
		./RAiSD-AI -op IMG-GEN -n "$ID"TrainingData -I "$outpath"/RAW/TRAIN/SWEEP/Simulations.txt -icl sweepTR -L $length -its $center -w $width -f -typ $typ -O
		
		./RAiSD-AI -op IMG-GEN -n "$ID"TestingData -I "$outpath"/RAW/TEST/NEUTRAL/Simulations.txt -icl neutralTE -L $length -its $center -w $width -f -frm -typ $typ -O
		./RAiSD-AI -op IMG-GEN -n "$ID"TestingData -I "$outpath"/RAW/TEST/SWEEP/Simulations.txt -icl sweepTE -L $length -its $center -w $width -f -typ $typ -O
		
	elif [ "$bin" == "1" ]; then
		./RAiSD-AI -op IMG-GEN -n "$ID"TrainingData -I "$outpath"/RAW/TRAIN/NEUTRAL/Simulations.txt -icl neutralTR -L $length -its $center -w $width -f -bin -frm -typ $typ -O 
		./RAiSD-AI -op IMG-GEN -n "$ID"TrainingData -I "$outpath"/RAW/TRAIN/SWEEP/Simulations.txt -icl sweepTR -L $length -its $center -w $width -f -bin -typ $typ -O
		
		./RAiSD-AI -op IMG-GEN -n "$ID"TestingData -I "$outpath"/RAW/TEST/NEUTRAL/Simulations.txt -icl neutralTE -L $length -its $center -w $width -f -bin -frm -typ $typ -O 
		./RAiSD-AI -op IMG-GEN -n "$ID"TestingData -I "$outpath"/RAW/TEST/SWEEP/Simulations.txt -icl sweepTE -L $length -its $center -w $width -f -bin -typ $typ -O
		
	else
		echo -e "Invalid input of -b"
		return 0;
	fi

	./RAiSD-AI -op MDL-GEN -n "$ID"Model -I RAiSD_Images."$ID"TrainingData -arc $arc -e $epoch -f -O
	
	./RAiSD-AI -op MDL-TST -n "$ID"Result -mdl RAiSD_Model."$ID"Model -f -I RAiSD_Images."$ID"TestingData -clp 2 sweepTR=sweepTE neutralTR=neutralTE


elif [ "$mode" == "4" ]; then		# Training data generation, model training and scanning
	
	python Data_Generation.py -i $seed -C $catalog -d $demography -c $chro -g $genmap -l $left -r $right -p $population -P $popsize -s $numsam -n $numpop -m neutral -a $scalingfactor -o "$outpath"/RAW/TRAIN/NEUTRAL

	python Data_Generation.py -i $seed -C $catalog -d $demography -c $chro -g $genmap -l $left -r $right -p $population -P $popsize -s $numsam -n $numpop -m sweep -S $selcoef -t $gentime -f $minfre -a $scalingfactor -o "$outpath"/RAW/TRAIN/SWEEP


	if [ "$bin" == "0" ]; then
		./RAiSD-AI -op IMG-GEN -n "$ID"TrainingData -I "$outpath"/RAW/TRAIN/NEUTRAL/Simulations.txt -icl neutralTR -L $length -its $center -w $width -f -frm -typ $typ -O
		./RAiSD-AI -op IMG-GEN -n "$ID"TrainingData -I "$outpath"/RAW/TRAIN/SWEEP/Simulations.txt -icl sweepTR -L $length -its $center -w $width -f -typ $typ -O
		
	elif [ "$bin" == "1" ]; then
		./RAiSD-AI -op IMG-GEN -n "$ID"TrainingData -I "$outpath"/RAW/TRAIN/NEUTRAL/Simulations.txt -icl neutralTR -L $length -its $center -w $width -f -bin -frm -typ $typ -O 
		./RAiSD-AI -op IMG-GEN -n "$ID"TrainingData -I "$outpath"/RAW/TRAIN/SWEEP/Simulations.txt -icl sweepTR -L $length -its $center -w $width -f -bin -typ $typ -O
		
	else
		echo -e "Invalid input of -b"
		return 0;
	fi

	./RAiSD-AI -op MDL-GEN -n "$ID"Model -I RAiSD_Images."$ID"TrainingData -arc $arc -e $epoch -f -O
	
	if [ "$haploid" == "0" ]; then
		python Data_Generation.py -i $seed -C $catalog -d $demography -c $chro -g $genmap -l $left -r $right -p $population -P $popsize -s $numsam -n 1 -m sweep -S $selcoef -t $gentime -f $minfre -a $scalingfactor -o "$outpath"/RAW/SCAN
	
	elif [ "$haploid" == "1" ]; then
		python Data_Generation.py -i $seed -C $catalog -d $demography -c $chro -g $genmap -l $left -r $right -p $population -P $popsize -s $(($numsam * 2)) -n 1 -m sweep -S $selcoef -t $gentime -f $minfre -a $scalingfactor -o "$outpath"/RAW/SCAN
		
	fi
	
	./RAiSD-AI -n FAST-NN-PT-BINFRQPOS-SCAN -mdl RAiSD_Model."$ID"Model -f -op SWP-SCN -I "$outpath"/RAW/SCAN/Simulations.txt -L $length -frm -T $center -d $distance -G $grid -pci 1 1 -P -O

else
	echo -e "Invalid testing mode."

fi
	
