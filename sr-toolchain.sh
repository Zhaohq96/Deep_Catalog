#!/bin/bash

# Initialization

catalog="HomSap"
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

while getopts "C:d:c:g:l:r:p:P:s:n:T:S:t:f:a:W:b:N:e:b:A:i:m:G:D:L:o:" opt
do
	case "${opt}" in
		C) catalog=${OPTARG};;
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




if [[ "$mode" == "0" ]]; then		# Training data generation and model training
	
	python Data_Generation.py -C $catalog -d $demography -c $chro -g $genmap -l $left -r $right -p $population -P $popsize -s $numsam -n $numpop -m neutral -a $scalingfactor -o "$outpath"/RAW/NEUTRAL

	python Data_Generation.py -C $catalog -d $demography -c $chro -g $genmap -l $left -r $right -p $population -P $popsize -s $numsam -n $numpop -m sweep -S $selcoef -t $gentime -f $minfre -a $scalingfactor -o "$outpath"/RAW/SWEEP


	if [[ "$bin" == "0" ]]; then
		./RAiSD-AI -op IMG-GEN -n "$ID"TrainingData -I "$outpath"/RAW/NEUTRAL/Simulations.txt -icl neutralTR -L $length -its $center -w $width -f -frm -typ $typ -O
		./RAiSD-AI -op IMG-GEN -n "$ID"TrainingData -I "$outpath"/RAW/SWEEP/Simulations.txt -icl sweepTR -L $length -its $center -w $width -f -typ $typ -O
		
	elif [[ "$bin" == "1" ]]; then
		./RAiSD-AI -op IMG-GEN -n "$ID"TrainingData -I "$outpath"/RAW/NEUTRAL/Simulations.txt -icl neutralTR -L $length -its $center -w $width -f -bin -frm -typ $typ -O 
		./RAiSD-AI -op IMG-GEN -n "$ID"TrainingData -I "$outpath"/RAW/SWEEP/Simulations.txt -icl sweepTR -L $length -its $center -w $width -f -bin -typ $typ -O
		
	else
		echo "Invalid input of -b"
		return 0;
	fi

	./RAiSD-AI -op MDL-GEN -n "$ID"Model -I RAiSD_Images."$ID"TrainingData -arc $arc -e $epoch -f -O
	


elif [[ "$mode" == "1" ]]; then	# Testing data generation and testing based on an already-trained model

	python Data_Generation.py -C $catalog -d $demography -c $chro -g $genmap -l $left -r $right -p $population -P $popsize -s $numsam -n $numpop -m neutral -a $scalingfactor -o "$outpath"/RAW/NEUTRAL

	python Data_Generation.py -C $catalog -d $demography -c $chro -g $genmap -l $left -r $right -p $population -P $popsize -s $numsam -n $numpop -m sweep -S $selcoef -t $gentime -f $minfre -a $scalingfactor -o "$outpath"/RAW/SWEEP
	
	if [[ "$bin" == "0" ]]; then
		./RAiSD-AI -op IMG-GEN -n "$ID"TestingData -I "$outpath"/RAW/NEUTRAL/Simulations.txt -icl neutralTE -L $length -its $center -w $width -f -frm -typ $typ -O
		./RAiSD-AI -op IMG-GEN -n "$ID"TestingData -I "$outpath"/RAW/SWEEP/Simulations.txt -icl sweepTE -L $length -its $center -w $width -f -typ $typ -O
		
	elif [[ "$bin" == "1" ]]; then
		./RAiSD-AI -op IMG-GEN -n "$ID"TestingData -I "$outpath"/RAW/NEUTRAL/Simulations.txt -icl neutralTE -L $length -its $center -w $width -f -bin -frm -typ $typ -O 
		./RAiSD-AI -op IMG-GEN -n "$ID"TestingData -I "$outpath"/RAW/SWEEP/Simulations.txt -icl sweepTE -L $length -its $center -w $width -f -bin -typ $typ -O
		
	else
		echo "Invalid input of -b"
		return 0;
	fi
	
	./RAiSD-AI -op MDL-TST -n "$ID"Result -mdl "$input" -f -I RAiSD_Images."$ID"TestingData -clp 2 sweepTR=sweepTE neutralTR=neutralTE
	
elif [[ "$mode" == "2" ]]; then	# Tesing data generation and scanning based on an already-trained model

	python Data_Generation.py -C $catalog -d $demography -c $chro -g $genmap -l $left -r $right -p $population -P $popsize -s $numsam -n $numpop -m sweep -S $selcoef -t $gentime -f $minfre -a $scalingfactor -o "$outpath"/RAW/SWEEP
	
	./RAiSD-AI -n FAST-NN-PT-BINFRQPOS-SCAN -mdl "$input" -f -op SWP-SCN -I "$outpath"/RAW/SWEEP/Simulations.txt -L $length -frm -T $target -d $distance -G $grid -pci 1 1 -P -O

elif [[ "$mode" == "3" ]]; then	# Training & tesing data generation, training the model on training dataset and tesing on the trained model
	
	python Data_Generation.py -C $catalog -d $demography -c $chro -g $genmap -l $left -r $right -p $population -P $popsize -s $numsam -n $numpop -m neutral -a $scalingfactor -o "$outpath"/RAW/TRAIN/NEUTRAL

	python Data_Generation.py -C $catalog -d $demography -c $chro -g $genmap -l $left -r $right -p $population -P $popsize -s $numsam -n $numpop -m sweep -S $selcoef -t $gentime -f $minfre -a $scalingfactor -o "$outpath"/RAW/TRAIN/SWEEP
	
	python Data_Generation.py -C $catalog -d $demography -c $chro -g $genmap -l $left -r $right -p $population -P $popsize -s $numsam -n $testing -m neutral -a $scalingfactor -o "$outpath"/RAW/TEST/NEUTRAL

	python Data_Generation.py -C $catalog -d $demography -c $chro -g $genmap -l $left -r $right -p $population -P $popsize -s $numsam -n $testing -m sweep -S $selcoef -t $gentime -f $minfre -a $scalingfactor -o "$outpath"/RAW/TEST/SWEEP


	if [[ "$bin" == "0" ]]; then
		./RAiSD-AI -op IMG-GEN -n "$ID"TrainingData -I "$outpath"/RAW/TRAIN/NEUTRAL/Simulations.txt -icl neutralTR -L $length -its $center -w $width -f -frm -typ $typ -O
		./RAiSD-AI -op IMG-GEN -n "$ID"TrainingData -I "$outpath"/RAW/TRAIN/SWEEP/Simulations.txt -icl sweepTR -L $length -its $center -w $width -f -typ $typ -O
		
		./RAiSD-AI -op IMG-GEN -n "$ID"TestingData -I "$outpath"/RAW/TEST/NEUTRAL/Simulations.txt -icl neutralTE -L $length -its $center -w $width -f -frm -typ $typ -O
		./RAiSD-AI -op IMG-GEN -n "$ID"TestingData -I "$outpath"/RAW/TEST/SWEEP/Simulations.txt -icl sweepTE -L $length -its $center -w $width -f -typ $typ -O
		
	elif [[ "$bin" == "1" ]]; then
		./RAiSD-AI -op IMG-GEN -n "$ID"TrainingData -I "$outpath"/RAW/TRAIN/NEUTRAL/Simulations.txt -icl neutralTR -L $length -its $center -w $width -f -bin -frm -typ $typ -O 
		./RAiSD-AI -op IMG-GEN -n "$ID"TrainingData -I "$outpath"/RAW/TRAIN/SWEEP/Simulations.txt -icl sweepTR -L $length -its $center -w $width -f -bin -typ $typ -O
		
		./RAiSD-AI -op IMG-GEN -n "$ID"TestingData -I "$outpath"/RAW/TEST/NEUTRAL/Simulations.txt -icl neutralTE -L $length -its $center -w $width -f -bin -frm -typ $typ -O 
		./RAiSD-AI -op IMG-GEN -n "$ID"TestingData -I "$outpath"/RAW/TEST/SWEEP/Simulations.txt -icl sweepTE -L $length -its $center -w $width -f -bin -typ $typ -O
		
	else
		echo "Invalid input of -b"
		return 0;
	fi

	./RAiSD-AI -op MDL-GEN -n "$ID"Model -I RAiSD_Images."$ID"TrainingData -arc $arc -e $epoch -f -O
	
	./RAiSD-AI -op MDL-TST -n "$ID"Result -mdl RAiSD_Model."$ID"Model -f -I RAiSD_Images."$ID"TestingData -clp 2 sweepTR=sweepTE neutralTR=neutralTE


elif [[ "$mode" == "4" ]]; then		# Training data generation and model training
	
	python Data_Generation.py -C $catalog -d $demography -c $chro -g $genmap -l $left -r $right -p $population -P $popsize -s $numsam -n $numpop -m neutral -a $scalingfactor -o "$outpath"/RAW/TRAIN/NEUTRAL

	python Data_Generation.py -C $catalog -d $demography -c $chro -g $genmap -l $left -r $right -p $population -P $popsize -s $numsam -n $numpop -m sweep -S $selcoef -t $gentime -f $minfre -a $scalingfactor -o "$outpath"/RAW/TRAIN/SWEEP


	if [[ "$bin" == "0" ]]; then
		./RAiSD-AI -op IMG-GEN -n "$ID"TrainingData -I "$outpath"/RAW/TRAIN/NEUTRAL/Simulations.txt -icl neutralTR -L $length -its $center -w $width -f -frm -typ $typ -O
		./RAiSD-AI -op IMG-GEN -n "$ID"TrainingData -I "$outpath"/RAW/TRAIN/SWEEP/Simulations.txt -icl sweepTR -L $length -its $center -w $width -f -typ $typ -O
		
	elif [[ "$bin" == "1" ]]; then
		./RAiSD-AI -op IMG-GEN -n "$ID"TrainingData -I "$outpath"/RAW/TRAIN/NEUTRAL/Simulations.txt -icl neutralTR -L $length -its $center -w $width -f -bin -frm -typ $typ -O 
		./RAiSD-AI -op IMG-GEN -n "$ID"TrainingData -I "$outpath"/RAW/TRAIN/SWEEP/Simulations.txt -icl sweepTR -L $length -its $center -w $width -f -bin -typ $typ -O
		
	else
		echo "Invalid input of -b"
		return 0;
	fi

	./RAiSD-AI -op MDL-GEN -n "$ID"Model -I RAiSD_Images."$ID"TrainingData -arc $arc -e $epoch -f -O
	
	python Data_Generation.py -C $catalog -d $demography -c $chro -g $genmap -l $left -r $right -p $population -P $popsize -s $numsam -n $numpop -m sweep -S $selcoef -t $gentime -f $minfre -a $scalingfactor -o "$outpath"/RAW/SCAN
	
	./RAiSD-AI -n FAST-NN-PT-BINFRQPOS-SCAN -mdl "$input" -f -op SWP-SCN -I "$outpath"/RAW/SCAN/Simulations.txt -L $length -frm -T $center -d $distance -G $grid -pci 1 1 -P -O

else
	echo "Invalid testing mode."

fi
	
