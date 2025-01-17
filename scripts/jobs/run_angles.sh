#!/bin/sh

# SLURM options:

#SBATCH --job-name=SNDetectorEffects        	 # Job name
#SBATCH --partition=htc                  # Partition choice (most generally we work with htc, but for quick debugging you can use
										 #					 #SBATCH --partition=flash. This avoids waiting times, but is limited to 1hr)
#SBATCH --mem=32G                     	 # RAM
#SBATCH --licenses=sps                   # When working on sps, must declare license!!
#SBATCH --ntasks=1

#SBATCH --time=0-1                 	 # Time for the job in format “minutes:seconds” or  “hours:minutes:seconds”, “days-hours”
#SBATCH --cpus-per-task=6                # Number of CPUs
#SBATCH --output="/pbs/home/m/mpetro/sps_mpetro/Projects/PhD/SNDetectorEffects/scripts/jobs/logs/%A.out"
#SBATCH --error="/pbs/home/m/mpetro/sps_mpetro/Projects/PhD/SNDetectorEffects/scripts/jobs/logs/%A.err"

JULIA=/sps/nemo/scratch/mpetro/PROGRAMS/julia/juliaup/julia-1.10.0+0.x64.linux.gnu/bin
SCRIPTS=/pbs/home/m/mpetro/sps_mpetro/Projects/PhD/SNDetectorEffects/scripts/analysis
PROJECT="/pbs/home/m/mpetro/sps_mpetro/Projects/PhD/SNDetectorEffects"

$JULIA/julia --project=$PROJECT $SCRIPTS/angles.jl -t 6
