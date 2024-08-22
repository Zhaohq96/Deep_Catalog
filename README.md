# Deep_Catalog

## About
Deep_Catalog is a deep-learning-model generator for detecting selective sweeps based on stdpopsim and RAiSD-AI. It utilizes stdpopsim to simulate the datasets and uses RAiSD-AI to train and test the models.

## Enviromental Setup
Deep_Catalog requires stdpopsim and RAiSD-AI for data and model generations. According to our many failed experiences, we recommend to use Anaconda for building a virtual environment to avoid package dependencies. The installation of Anaconda can be found via https://www.anaconda.com/

To build virtual environment with stdpopsim by command:

``conda create -n myenv -c conda-forge -c bioconda python=3.8 stdpopsim bcftools slim=4.1 msprime=1.2.0``

"myenv" as the name of virtual environment, can be changed.

To activate virtual environment:

``conda activate myenv``

To install the packages that RAiSD-AI requires in the same virtual environment by the command:

``conda install pytorch=2.0.1 torchvision=0.15.2 protobuf tensorflow=2.8 keras=2.8 numpy h5py tensorboard=2.8 pillow=7.0.0``

RAiSD-AI can be downloaded and compiled via https://github.com/alachins/raisd-ai, or use the command directly on the terminal:

```
 mkdir RAiSD-AI; cd RAiSD-AI; wget https://github.com/alachins/RAiSD-AI/archive/refs/heads/master.zip; unzip master.zip; cd RAiSD-AI-master; ./compile-RAiSD-AI.sh
```

To deactivate virtual environment:

``conda deactivate``

## Source Code Download and File Path Reassignment
The zip file of the source code can be downloaded via github. Then the following command can be used to unzip the file and to be in the path of main folder.

``unzip Deep_Catalog-main.zip``

``cd Deep_Catalog-main``

All the files should be moved to the path of RAiSD-AI by the command:

``mv * PathToRAiSD-AI``

## A quick example
The users can easily use commandlines to generate simulation datasets, train deep learning models and test. Here is an example to generate datasets simulating the genomic data of Homo Sapiens with a specific genetic scenario and train and test the deep learning model based on the datasets:

``sh sr-toolchain.sh -m 3 -a 10 -o Example -N Example -n 1000 -d OutOfAfrica_3G09 -g PyrhoYRI_GRCh38 -p YRI -l 0 -r 1000000 -c chr1 -s 64 -W 128 -b 1 -T 0 -e 10``

The simulation datasets will be generated in the path _Example/RAW_, where both the subfolders _TRAIN_ and _TEST_ consists of two folders, _NEUTRAL_ and _SWEEP_, containing the neutral simulations and the simulations with sweeps.

The terminal will display the information of input data generation, training process and testing results. The input data generated for deep learning model will be in the folders _RAiSD_Images.ExampleTrainingData_ (data for training) and _RAiSD_Images.ExampleTrainingData_ (data for testing). The training model will be stored in _RAiSD_Modle.ExampleModel_.

## In-tool Help
Deep_Catalog provides five optional modes for users, including 1) generating the deep learning model based on user-specified datasets, 2) testing a dataset using an already-existing training model, 3) generating and testing the deep learning model based on user-specified datasets, 4) scanning the whole genome using an already-existing training model, 5) generating the deep learning model based on user-specified datasets and scanning the data using the training model.

To check the description by the command:

``sh sr-toolchain.sh -h``

The generated message is the following. 
