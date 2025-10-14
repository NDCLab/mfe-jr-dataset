#!/bin/bash



#SBATCH --job-name=mfeJr        # create a short name for your job
#SBATCH --account=iacc_gbuzzell
#SBATCH --nodes=1                # node count
#SBATCH --ntasks=1               # total number of tasks across all nodes
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --partition=highmem1            # partition name (use high memory nodes)
#SBATCH --qos=highmem1                  # QOS

#SBATCH --mail-type=end          # send email when job ends
#SBATCH --mail-user=khoss005@fiu.edu

module load matlab-2021b
pwd; hostname; date


matlab -nodisplay < MADE_mfe_jr.m