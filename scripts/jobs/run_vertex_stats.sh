#!/bin/sh

# SLURM options:

#SBATCH --job-name=SNDetectorEffects        	 # Job name
#SBATCH --partition=htc                  # Partition choice (most generally we work with htc, but for quick debugging you can use
										 #					 #SBATCH --partition=flash. This avoids waiting times, but is limited to 1hr)
#SBATCH --mem=64G                     	 # RAM
#SBATCH --licenses=sps                   # When working on sps, must declare license!!

#SBATCH --time=1-0                 	 	 # Time for the job in format “minutes:seconds” or  “hours:minutes:seconds”, “days-hours”
#SBATCH --cpus-per-task=6                # Number of CPUs

JULIA=/sps/nemo/scratch/mpetro/PROGRAMS/julia/juliaup/julia-1.10.0+0.x64.linux.gnu/bin
SCRIPTS=/pbs/home/m/mpetro/sps_mpetro/Projects/PhD/SNDetectorEffects/scripts/analysis

$JULIA/julia --project="/pbs/home/m/mpetro/sps_mpetro/Projects/PhD/SNDetectorEffects" $SCRIPTS/vertex_stats.jl -t 6
