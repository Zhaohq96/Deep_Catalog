import stdpopsim
import numpy as np
import sys, time, os
import getopt
import argparse
import shutil
import random
import subprocess
import string
import glob

from src import Std_Simulation, Concatenate_VCF

def help():

	print("This is a python script to generate simulatons of genetic datasets in VCF format, using stdpopsim as its back-end.\n")
	print("General parameters:")
	
	print("\t-C/--catalog: a specific catalog of species (str) (default: HomSap)")
	print("\t-d/--demography: a model of demographic history (str) (default: None)")
	print("\t-c/--chr: a chromosome of the catalog (str) (default: chr1)")
	print("\t-g/--gen-map: a genetic map (str) (default: None)")
	print("\t-l/--left: the left ordinate of the simulated region (int) (default: 1000000)")
	print("\t-r/--right: the right ordinate of the simulated region (int) (default: 2000000)")
	print("\t-p/--population: a specific population of the specie (str) (default: pop_0)")
	print("\t-P/--pop-size: the size of a population (int) (default: 100000)")
	print("\t-s/--num-sample: the number of samples in a population (str) (default: 50)")
	print("\t-n/--num-pop: the number of populations to simulate (int) (default: 1)")
	print("\t-m/--sim-type: the data of neutrality (neutral) or the data of selective sweeps (sweep, see the detailed parameters below) to simulate (str) (default: neutral)")
	print("\t-a/--scaling-factor: the rescale model parameter to speed up simulation (int) (default: 1)")
	print("\t-o/--output: the path to the output files (str)\n")
	
	print("Parameters for sweep only")
	print("\t-S/--sele-coef: the selection coefficient (float) (default: 0.5)")
	print("\t-t/--gen-time: the generation time of the mutation (int) (default: 1000)")
	print("\t-f/--min-freq: the minimum frequency of the mutation at the end (float) (default: 1)")


def main(argv):

    # Initializing
	catalog = "HomSap"
	demo_model = "None"
	chrm = "chr1"
	gen_map = "None"
	left = 1000000
	right = 2000000
	pop = "pop_0"
	pop_size = 100000
	num_sam = 50
	num_pop = 1
	sim_type = "neutral"
	sel_coef = 0.5
	mut_gen_time = 1000
	min_fre = 1
	scaling = 1
	
	
	opts, ars = getopt.getopt(argv, "hC:d:c:g:l:r:p:P:s:n:m:S:t:f:a:o:", ["help", "catalog=", "demography=", "chr=", "gen-map=", "left=", "right=", "population=", "pop-size=", "num-sample=", "num-pop=", "sim-type=", "sele-coef=", "gen-time=", "min-freq=", "scaling-factor=", "output="])
    
	for opt, arg in opts:
		if opt in ("-h", "--help"):
			help()
			return 0
		elif opt in ("-C", "--catalog"):
			catalog = arg
		elif opt in ("-d", "--demography"):
    			demo_model = arg
		elif opt in ("-c", "--chr"):
			chrm = arg
		elif opt in ("-g", "--gen-map"):
			gen_map = arg
		elif opt in ("-l", "--left"):
			left = arg
		elif opt in ("-r", "--right"):
			right = arg
		elif opt in ("-p", "--population"):
			pop = arg
		elif opt in ("-P", "--pop-size"):
			pop_size = arg
		elif opt in ("-s", "--num-sample"):
			num_sam = arg
		elif opt in ("-n", "--num-pop"):
			num_pop = arg
		elif opt in ("-m", "--sim-type"):
			sim_type = arg
		elif opt in ("-S", "--sele-coef"):
			sel_coef = arg
		elif opt in ("-t", "--gen-time"):
			mut_gen_time = arg
		elif opt in ("-f", "--min-freq"):
			min_fre = arg
		elif opt in ("-a", "--scaling-factor"):
			scaling = arg
		elif opt in ("-o", "--output"):
			output = arg
	
	
    # Generate simulations	
	Std_Simulation.simulator(catalog, demo_model, chrm, gen_map, left, right, pop, pop_size, num_sam, num_pop, sim_type, sel_coef, mut_gen_time, min_fre, scaling, output)
	
    # Concatenate output files into one VCF file
	Concatenate_VCF.concatenate_vcf_files(output)

    # Remove temporary files
	for file in glob.glob(str(output) + '/*.vcf'):
		os.remove(file)		
		
if __name__ == "__main__":
    main(sys.argv[1:])	
