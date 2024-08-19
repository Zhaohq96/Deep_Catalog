import sys, time, os
import shutil
import subprocess
import string
import glob

def concatenate_vcf_files(path):

    # Find all VCF files in the current directory
	vcf_files = glob.glob(path + '/*.vcf')
    	
	if not vcf_files:
		print("No VCF files found in the directory.")
		return
	
	os.makedirs("modified_vcfs", exist_ok=True)
	
	for i, input_vcf in enumerate(vcf_files):
		output_vcf = f"modified_vcfs/modified_{i}.vcf"
		chrom_id = f"chr{i+1}"
		
		with open("chr_map.txt", "w") as chr_map:
        		chr_map.write(f"0\t{chrom_id}\n")
		subprocess.run([
        		"bcftools", "annotate", "--rename-chrs", "chr_map.txt",
        		input_vcf, "-o", output_vcf
    		])
    # Prepare the command to concatenate using bcftools merge
	modified_vcfs = [f"modified_vcfs/modified_{i}.vcf" for i in range(len(vcf_files))]
	
	subprocess.run(["bcftools", "concat", *modified_vcfs, "-o", str(path) + "/Simulations.txt"])

    # Remove the temporary files
	os.remove("chr_map.txt")
	shutil.rmtree("modified_vcfs")
	


