# Generate random seeds a priori for reproducibility

using Distributions, Random

# random seeds for Monte Carlo estimation of optimality gap
Random.seed!(9518)
const randomSeeds_MC = ceil.(Int64,rand(Uniform(0,10000),maxNumMCReplicates))

# random seeds for constructing different model replicates
Random.seed!(8543)
const randomSeeds_models = ceil.(Int64,rand(Uniform(0,10000),maxNumModelReplicates))

# random seeds for constructing different data replicates for a given model
Random.seed!(7654)
const randomSeeds_data = ceil.(Int64,rand(Uniform(0,10000),maxNumDataReplicates))