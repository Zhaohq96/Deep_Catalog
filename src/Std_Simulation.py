import stdpopsim
import numpy as np
import sys, time, os, shutil
import random
import string

def simulator(catalog, demo_model, chrm, gen_map, Left, Right, pop, pop_size, num_sam, num_pop, sim_type, sel_coef, mut_gen_time, min_fre, scaling, output):
    
    # Get catalog and basic information	
	species = stdpopsim.get_species(catalog)
	
	if(demo_model=='None'):
		model = stdpopsim.PiecewiseConstantSize(species.population_size)
	else: 
		model = species.get_demographic_model(demo_model)
		
	if(gen_map=='None'):
		contig = species.get_contig(chrm, left=int(Left), right=int(Right))
	else: 
		contig = species.get_contig(
	    		chrm, genetic_map=gen_map, left=int(Left), right=int(Right), mutation_rate=model.mutation_rate
		)

	samples = {str(pop): int(num_sam)}

    # Simulate hard sweep
	locus_id = "hard sweep"
	coordinate = round(int(Left) + contig.length / 2)
	contig.add_single_site(
	    id=locus_id,
	    coordinate=coordinate,
	)

	extended_events = stdpopsim.ext.selective_sweep(
	    single_site_id=locus_id,
	    population=pop,
	    selection_coeff=float(sel_coef),
	    mutation_generation_ago=int(mut_gen_time),
	    min_freq_at_end=float(min_fre),
	)

    # Generate simulations
	random_numbers = random.sample(range(1, 10000000), int(num_pop))
	
	if not os.path.exists(output):
		os.makedirs(output)
	
	else:
		shutil.rmtree(output)
		os.makedirs(output)
	
	engine = stdpopsim.get_engine("slim")
	
    ## Generate neutral simulations
	if(sim_type=="neutral"):
		for val in random_numbers:	
			ts_sim = engine.simulate(
			    model,
			    contig,
			    samples,
			    seed=int(val),
			    # no extended events
			    slim_scaling_factor=int(scaling),
			    slim_burn_in=0.1,
			)
			with open(str(output) + "/simulation" + str(val) + ".vcf", "w") as vcf_file:
	    			ts_sim.write_vcf(vcf_file, contig_id="0")	    			
    
    ## Generate simulations with hard sweep    
	elif(sim_type=="sweep"):
		for val in random_numbers:
			ts_sim = engine.simulate(
			    model,
			    contig,
			    samples,
			    seed=int(val),
			    extended_events=extended_events,
			    slim_scaling_factor=int(scaling),
			    slim_burn_in=0.1,
			)
			with open(str(output) + "/simulation" + str(val) + ".vcf", "w") as vcf_file:
	    			ts_sim.write_vcf(vcf_file, contig_id="0")
	    		
	else:
		print("The simulated region should be neutral or a sweep.")
		
		return -1
		
	

