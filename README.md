# Deep_Catalog

## About
Deep_Catalog is a deep-learning-model generator for detecting selective sweeps based on stdpopsim and RAiSD-AI. It utilizes stdpopsim to simulate the datasets and uses RAiSD-AI to train the models.

## Enviromental Setup
Deep_Catalog requires stdpopsim and RAiSD-AI for data and model generations. According to our many failed experiences, we recommend to use Anaconda for building a virtual environment to avoid package dependencies. The installation of Anaconda can be found via https://www.anaconda.com/

RAiSD-AI can be downloaded and compiled via https://github.com/alachins/raisd-ai.

To build virtual environment with stdpopsim by command:

``conda create -n myenv -c conda-forge -c bioconda python=3.8 stdpopsim bcftools slim=4.1 msprime=1.2.0``

"myenv" as the name of virtual environment, can be changed.

To activate virtual environment:

``conda activate myenv``

To install the packages that RAiSD-AI requires in the same virtual environment by the command:

``conda install pytorch=2.0.1 torchvision=0.15.2 protobuf tensorflow=2.8 keras=2.8 numpy h5py tensorboard=2.8 pillow=7.0.0``

To deactivate virtual environment:

``conda deactivate``

## Source Code Download and File Path Reassignment
The zip file of the source code can be downloaded via github. Then the following command can be used to unzip the file and to be in the path of main folder.

``unzip Deep_Catalog-main.zip``

``cd Deep_Catalog-main``

All the file should be moved to the same path of RAiSD-AI by the command:

``mv * _PathToRAiSD-AI_``
