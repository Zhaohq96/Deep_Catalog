# Deep_Catalog

## About
Deep_Catalog is a deep-learning-model generator for detecting selective sweeps based on stdpopsim (https://popsim-consortium.github.io/stdpopsim-docs/stable/index.html) and RAiSD-AI (https://github.com/alachins/raisd-ai). It utilizes stdpopsim to simulate the datasets and uses RAiSD-AI to train and test the models.

## Quick environment setup and running examples with command lines
It is necessary to get Anaconda installed ready. The installation of Anaconda can be found via https://www.anaconda.com/.

After installation of Anaconda, you can use the following command to activate base environment.

``source path_to_anaconda3/bin/activate``

where _path_to_anaconda3_ is the path of Anaconda folder.

### Commands for environment setup
__Step1:__ Virtual environment installation
```
 conda create -n myenv -c conda-forge -c bioconda python=3.8 stdpopsim bcftools slim=4.1 msprime=1.2.0; conda activate myenv; conda install pytorch=2.0.1 torchvision=0.15.2 protobuf tensorflow=2.8 keras=2.8 numpy h5py tensorboard=2.8 pillow=7.0.0;
```
__Step2:__ RAiSD-AI installation and compilation
```
 mkdir RAiSD-AI; cd RAiSD-AI; wget https://github.com/alachins/RAiSD-AI/archive/refs/heads/master.zip; unzip master.zip; cd RAiSD-AI-master; ./compile-RAiSD-AI.sh
```
__Step3:__ Deep_Catalog download
```
 wget https://github.com/Zhaohq96/Deep_Catalog/archive/refs/heads/master.zip; unzip master.zip; cd Deep_Catalog-main/; mv README.md README-DC.md; mv * ../; cd ..; rm -r Deep_Catalog-main/;
```

### Commands for quick examples
#### Basic information about simulations
In the following examples, we simulated Yoruba (YRI) populations using the three-population out-of-Africa demographic model (OutOfAfrica_3G09). The simulations focus on chromosome 1, applying the YRI-specific recombination map from pyrho (PyrhoYRI_GRCh38). The simulated genome spans 1,000,000 base pairs, ranging from position 0 to 1,000,000. Each population consists of 64 individuals. For selection dataset, a selective sweep introduced at the center of each simulation. From the center of each simulation, 128 SNPs were extracted and converted into images to serve as input data for RAiSD-AI.

#### Example1: Generating a binary classifier to identify selective sweeps (Mode 0)
```
bash sr-toolchain.sh -m 0 -a 10 -o Mode0 -N Mode0 -n 20 -d OutOfAfrica_3G09 -g PyrhoYRI_GRCh38 -p YRI -l 0 -r 1000000 -c chr1 -s 64 -W 128 -b 1 -T 0 -e 10
```
This command generates 20 simulations for each class (neutral and sweep) and then trains a CNN model.


#### Example2: Performing classification using a trained model  (Mode 1)
```
bash sr-toolchain.sh -m 1 -a 10 -o Mode1 -N Mode1 -n 5 -d OutOfAfrica_3G09 -g PyrhoYRI_GRCh38 -p YRI -l 0 -r 1000000 -c chr1 -s 64 -W 128 -b 1 -T 0 -i RAiSD_Model.Mode0Model
```
This command generates 5 simulations per class for classification using the CNN model from __Example1__.


#### Example3: Utilizing a trained model to scan the simulation (Mode 2)
```
bash sr-toolchain.sh -m 2 -a 10 -o Mode1 -N Mode1 -n 1 -d OutOfAfrica_3G09 -g PyrhoYRI_GRCh38 -p YRI -l 0 -r 1000000 -c chr1 -s 64 -W 128 -b 1 -T 0 -i RAiSD_Model.Mode0Model -L 500000
```
This command generates a simulation with a selective sweep for scanning using the CNN model from __Example1__.


#### Example4: Generating a binary classifier for detecting selective sweeps and performing classification (Mode 3)
```
bash sr-toolchain.sh -m 3 -a 10 -o Mode3 -N Mode3 -n 20 -d OutOfAfrica_3G09 -g PyrhoYRI_GRCh38 -p YRI -l 0 -r 1000000 -c chr1 -s 64 -W 128 -b 1 -T 0 -e 10
```
This command generates 20 simulations per class for CNN training and 2 simulations per class for classification.


#### Example5: Generating a binary classifier for detecting selective sweeps and performing scanning (Mode 4)
```
bash sr-toolchain.sh -m 4 -a 10 -o Mode4 -N Mode4 -n 20 -d OutOfAfrica_3G09 -g PyrhoYRI_GRCh38 -p YRI -l 0 -r 1000000 -c chr1 -s 64 -W 128 -b 1 -T 0 -e 10 -L 500000
```
This command generates 20 simulations per class for CNN training and scans a simulation with a selective sweep using the trained model.

## In-tool Help
Deep_Catalog provides five optional modes for users, including 1) generating the deep learning model based on user-specified datasets, 2) testing a dataset using an already-existing training model, 3) generating and testing the deep learning model based on user-specified datasets, 4) scanning the whole genome using an already-existing training model, 5) generating the deep learning model based on user-specified datasets and scanning the data using the training model.

To check the description by the command:

``sh sr-toolchain.sh -h``

The generated message is the following. 

```
This script can be executed for generating genomic data and training deep learning models for detecting selective sweeps. It calls stdpopsim for data generation and RAiSD-AI for model traning.

Data generation parameter description

	-I: an initial seed for simulation (int) (default: 1)
	-C: a specific catalog (str) (default: HomSap)
	-d: demographic model (str) (default: None)
	-c: a specific chromosome (str) (default: chr1)
	-g: a genetic map (str) (default: None)
	-l: the left coordinate of the chromosome (int) (default: 1000000)
	-r: the right coordinate of the chromosome (int) (default: 2000000)
	-p: a specific population (str) (default: pop_0)
	-P: population size (int), it is ineffective when indicating a specific demographic model (default: 100000)
	-s: the number of samples (int) (default: 50)
	-n: the number of populations/simulations (int) (default: 1)
	-E: the distribution of fitness effects (default: None)
	-S: selection coefficient (float) (default: 0.5)
	-t: the generation time of selective sweeps (int) (default: 1000)
	-f: the minimum frequency at the end (float) (default: 1)
	-a: scaling factor to accelerate simulation (int) (default: 1)
	-o: output path of simulation (str) (default: None)


Deep_Catalog provides five optional modes for users by setting the option -m with 0, 1, 2, 3 or 4.

Required flag:
	-m: mode (int), 0) generating the deep learning model based on user-specified datasets, 1) testing a dataset using an already-existing training model, 2) generating and testing the deep learning model based on user-specified datasets, 3) scanning the whole genome using an already-existing training model, 4) generating the deep learning model based on user-specified datasets and scanning the data using the training model. (default: 3)

If -m in 0, 3:
	-N: a unique run ID that is used to name the output files of RAiSD-AI, i.e., the info file and the report(s) (str) (default: None)
	-W: window size (int) (default: 50)
	-T: specifies the data type. When generating images (PNG) -> 0: raw data in all channels (default), 1: raw data in one channel and pairwise snp distances in the other channels, 2: raw data in one channel and mu-var-scaled values in the other channels. When generating data in custom binary format -> 0: raw snp data and positions (default), 1: derived allele frequencies and positions. (int) (default: 0)
	-b: converts image data to a custom binary format (.snp). Only supported by the PyTorch implementation. 0: disable, 1: enable [PYTORCH-ONLY] (int) (default: 0)
	-A: a specific deep learning archtecture (str) (default: FAST-NN)
	-e: the number of epochs (int) (default: 10)

If -m in 1:
	-N: a unique run ID that is used to name the output files of RAiSD-AI, i.e., the info file and the report(s) (str) (default: None)
	-W: window size (int) (default: 50)
	-T: specifies the data type. When generating images (PNG) -> 0: raw data in all channels (default), 1: raw data in one channel and pairwise snp distances in the other channels, 2: raw data in one channel and mu-var-scaled values in the other channels. When generating data in custom binary format -> 0: raw snp data and positions (default), 1: derived allele frequencies and positions. (int) (default: 0)
	-b: converts image data to a custom binary format (.snp). Only supported by the PyTorch implementation. 0: disable, 1: enable [PYTORCH-ONLY] (int) (default: 0)
	-i: the path to an existing training model (str) (default: None)

If -m in 2:
	-H: specify if the catalog is haploid (0) or diploid (1) (int) (default: 1)
	-L: provides the selection target (in basepairs) and calculates the average distance (over all datasets in the input file) between the selection target and the reported locations (int) (default: None)
	-D: provides a maximum distance from the selection target (in base pairs) to calculate success rates, i.e., reported locations in the proximity of the target of selection (provided via -T) (int) (default: 50)
	-G: grid size (int) (default: 10)

If -m in 4:
	-H: specify if the catalog is haploid (0) or diploid (1) (int) (default: 1)
	-L: provides the selection target (in basepairs) and calculates the average distance (over all datasets in the input file) between the selection target and the reported locations (int) (default: None)
	-D: provides a maximum distance from the selection target (in base pairs) to calculate success rates, i.e., reported locations in the proximity of the target of selection (provided via -T) (int) (default: 50)
	-G: grid size (int) (default: 10)
	-i: the path to an existing training model (str) (default: None)
```

## Genomic data generation options
Deep_Catalog leverages stdpopsim to generate genomic simulations and utilizes an initial seed to conduct multiple simulations and concatenates the outputs into a single VCF file.

### General options
Deep_Catalog can be used to generate all possible demographic models supported by stdpopsim. There are following options to generate a neutral simulation.
```
	-I: an initial seed for simulation (int) (default: 1)
	-C: to specify the catalog to be simulated (str) (default: HomSap)
	-d: to specify a specific demographic model based on the sumulated catalog (str) (default: None)
	-c: which chromosome to be simulated (str) (default: chr1)
	-g: to specifiy a genome map of the catalog (str) (default: None)
	-l: the left coordinate of the chromosome (int) (default: 1000000)
	-r: the right coordinate of the chromosome (int) (default: 2000000)
	-p: to monitor the specific population during simulation (str) (default: pop_0)
	-P: the population size of simulations (int), it is ineffective when indicating a specific demographic model (default: 100000)
	-s: the number of samples (int) (default: 50)
	-n: the number of populations/simulations (int) (default: 1)
	-E: the distribution of fitness effects (default: None)
	-S: selection coefficient (float) (default: 0.5)
	-t: the generation time of selective sweeps (int) (default: 1000)
	-f: the minimum frequency at the end (float) (default: 1)
	-a: scaling factor to accelerate simulation (int) (default: 1)
	-o: output path of simulation (str) (default: None)
```
