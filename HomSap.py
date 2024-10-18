import subprocess
import time
from concurrent.futures import ProcessPoolExecutor

log_file = "command_times_log.txt"

# Function to run a command and measure execution time, then log it
def run_command(command):
    start_time = time.time()  # Record the start time
    subprocess.run(command)  # Execute the command
    end_time = time.time()  # Record the end time
    elapsed_time = end_time - start_time  # Calculate the elapsed time
    
    # Log the command and the time taken to a file
    with open(log_file, "a") as file:  # Open in append mode
        file.write(f"Command: {' '.join(command)}\n")
        file.write(f"Took {elapsed_time:.2f} seconds.\n\n")

# Required parameters - modify this part if needed
Catalog = ["HomSap"]
Demographic_Model = [["OutOfAfrica_3G09", "YRI"]] #, ["Africa_1B08", "African_Americans"]]
Number_Of_Simulation = ["100"]
Number_Of_Sample = ["100"]
Window_Size = ["128"]
Selection_Coefficient = ["0.5", "0.05"] # "0.005"]
Generation_Time = ["200", "1000"]
Minimum_Frequency_AtTheEnd = ["1"] #["0.5", "1"]
Scaling_Factor = ["20"]
Chromosome = [["chr2", "111006015", "111495070"]] #, ["chr22", "19036286", "19122412"], ["chrX", "64268081", "64395452"]]

Binary = ["1"]
Data_Type = ["1"]
Architecture = ["FAST-NN"]
Number_Of_Epochs = ["100"]

Max_workers = 4
# List to store all the commands
commands = []

# Iterate over the parameters using nested loops
for catalog in Catalog:
    for demographic in Demographic_Model:
        for num_sim in Number_Of_Simulation:
            for samples in Number_Of_Sample:
                for windows in Window_Size:
                    for sel_coe in Selection_Coefficient:
                        for generation_time in Generation_Time:
                            for min_fre in Minimum_Frequency_AtTheEnd:
                                for scaling_factor in Scaling_Factor:
                                    for Chr in Chromosome:
                                        for binary in Binary:
                                            for data_type in Data_Type:
                                                for arch in Architecture:
                                                    for epoch in Number_Of_Epochs:
                                        # Prepare the command to be executed
                                                        command = [
                                                            'bash', 'sr-toolchain.sh', '-m', '3',
                                                            '-a', scaling_factor,
                                                            '-C', catalog,
                                                            '-o', f'{catalog}_{demographic[1]}_{demographic[0]}_{Chr[0]}_Sim{num_sim}_Sam{samples}_Win{windows}_SelCoe{sel_coe}_GenTime{generation_time}_MinFreq{min_fre}_Scaling{scaling_factor}_Binary{binary}_DType{data_type}_Arch{arch}_Epoch{epoch}',
                                                            '-N', f'{catalog}_{demographic[1]}_{demographic[0]}_{Chr[0]}_Sim{num_sim}_Sam{samples}_Win{windows}_SelCoe{sel_coe}_GenTime{generation_time}_MinFreq{min_fre}_Scaling{scaling_factor}_Binary{binary}_DType{data_type}_Arch{arch}_Epoch{epoch}',
                                                            '-n', num_sim,
                                                            '-d', demographic[0],
                                                            '-g', 'HapMapII_GRCh38',
                                                            '-p', demographic[1],
                                                            '-l', Chr[1],
                                                            '-r', Chr[2],
                                                            '-c', Chr[0],
                                                            '-s', samples,
                                                            '-W', windows,
                                                            '-b', binary,
                                                            '-T', data_type,
                                                            '-e', epoch,
                                                            '-A', arch,
                                                            '-f', min_fre,
                                                            '-S', sel_coe,
                                                            '-t', generation_time,
                                                            '-I', '1'
                                                        ]
                                                        commands.append(command)

# Execute the commands in parallel using ProcessPoolExecutor
with ProcessPoolExecutor(max_workers=Max_workers) as executor:
    executor.map(run_command, commands)

