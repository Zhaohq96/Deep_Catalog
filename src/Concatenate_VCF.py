import os
import glob
import subprocess
import shutil

def concatenate_vcf_files(path):

    # Find all VCF files in the specified directory
    vcf_files = glob.glob(os.path.join(path, '*.vcf'))
    
    if not vcf_files:
        print("No VCF files found in the directory.")
        return
    
    # Create the 'modified_vcfs' folder under the specified 'path'
    modified_vcf_dir = os.path.join(path, "modified_vcfs")
    os.makedirs(modified_vcf_dir, exist_ok=True)
    
    # Path for the chr_map.txt file inside the 'modified_vcfs' folder
    chr_map_path = os.path.join(path, "chr_map.txt")
    
    for i, input_vcf in enumerate(vcf_files):
        output_vcf = os.path.join(modified_vcf_dir, f"modified_{i}.vcf")
        chrom_id = f"Simulation{i+1}"
        
        # Write chr_map.txt in the modified_vcfs directory
        with open(chr_map_path, "w") as chr_map:
            chr_map.write(f"0\t{chrom_id}\n")
        
        # Annotate VCF files
        subprocess.run([
            "bcftools", "annotate", "--rename-chrs", chr_map_path,
            input_vcf, "-o", output_vcf
        ])
    
    # Prepare the command to concatenate the modified VCF files using bcftools concat
    modified_vcfs = [os.path.join(modified_vcf_dir, f"modified_{i}.vcf") for i in range(len(vcf_files))]
    
    subprocess.run(["bcftools", "concat", *modified_vcfs, "-o", os.path.join(path, "Simulations.txt")])

    # Clean up temporary files
    os.remove(chr_map_path)
    shutil.rmtree(modified_vcf_dir)

