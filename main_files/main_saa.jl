# Main file for solving the full information SAA problem


using Distributions, StatsFuns, StatsBase, JuMP, Gurobi


const gurobi_env = Gurobi.Env()



# read these as inputs from the corresponding "instance file"
modRepNum = parse(Int, ARGS[1])
degNum = parse(Int, ARGS[2])
dataRepNum = parse(Int, ARGS[3])
saaRepNum = parse(Int, ARGS[4])



#*========= MODEL INFORMATION ==========
const caseNum = 1
const paramsFile = "../parameter_settings/params_case" * string(caseNum) * "_saa.jl"
#*======================================



#*========= INCLUDE FILES ====================
include("../maxParameters.jl")
include("../randomSeeds.jl")

include(paramsFile)
# the next two data files are defined in paramsFile
include(modelFile)
include(dataFile)

include("../solution_methods/solveModel.jl")
#*======================================



# set seed for reproducibility
Random.seed!(startingSeed)



# directory name for storing results
<<<<<<< HEAD
const baseDirName = "../output/case" * string(caseNum) * "_saa/" * "mod_" * string(modRepNum) * "/" * "deg_" * string(degNum) * "/"
=======
const baseDirName = "case" * string(caseNum) * "_saa/" * "mod_" * string(modRepNum) * "/" * "deg_" * string(degNum) * "/"
>>>>>>> 1b8ef5ad9b3efd57ea13e3c9dd95c8b42a5d2191
const subDirName = baseDirName * "rep_" * string(dataRepNum) * "/"
const subDirName2 = subDirName * "saa_" * string(saaRepNum) * "/"
mkpath(subDirName2)



#*========= PRINT OPTIONS ====================
const storeResults = false

const infoFile = "ddsp.txt"
const modelDataFile = "model_data.txt"

const saaObjFile = "saa_obj.txt"
const saaTimeFile = "saa_time.txt"
const covRealFile = "covariate_obs.txt"
#*======================================
	


#*========= GENERATE MODEL PARAMETERS ====================
	
Random.seed!(randomSeeds_models[modRepNum])	
numCovariates = 3

covariate_mean, covariate_covMat, coeff_true, var_coeff_true, var_coeff_scaling = generateBaseDemandModel(numCovariates)


#*========= STORE RESULTS ====================
if(storeResults)
	
	# write details to text file, including some key details about the test instance
	details_file = baseDirName * infoFile
	open(details_file, "w") do f
		write(f,"case number: $caseNum \n")
		write(f,"numResources: $numResources \n")
		write(f,"numCustomers: $numCustomers \n")
		write(f,"model replicate number: $modRepNum \n")
		write(f,"degree: $(degree[degNum]) \n")
		write(f,"heteroscedasticity level: $het_level \n")
		write(f,"demand_errors_scaling: $demand_errors_scaling \n")
		write(f,"numMCScenarios: $numMCScenarios \n\n")
		
		write(f,"randomSeeds_MC: $randomSeeds_MC \n")
		write(f,"randomSeeds_models: $randomSeeds_models \n")
		write(f,"randomSeeds_data: $randomSeeds_data \n")
	end	
	
	mod_data_file = baseDirName * modelDataFile
	open(mod_data_file, "w") do f
		write(f,"covariate_mean = $covariate_mean \n")
		write(f,"covariate_covMat = $covariate_covMat \n")
		write(f,"coeff_true = $coeff_true \n")
		write(f,"var_coeff_true = $var_coeff_true \n")
		write(f,"var_coeff_scaling = $var_coeff_scaling \n")
	end
	
end
#*============================================



#*========= GENERATE DATA REPLICATE ====================

Random.seed!(randomSeeds_data[dataRepNum])

covariate_obs = generateCovariateReal(numCovariates,covariate_mean,covariate_covMat)


#*========= STORE RESULTS ====================
if(storeResults)
	
	cov_real_file = subDirName * covRealFile
	open(cov_real_file, "w") do f
		write(f,"covariate_obs = $covariate_obs")
	end	
	
end
#*============================================



#*========= SOLVE THE FULL-INFORMATION SAA MODEL ====================

SAATime = @elapsed begin


# create scenarios from the true conditional distribution
Random.seed!(randomSeeds_MC[saaRepNum])

demand_scen_MC = generateTrueCondScenarios(numMCScenarios,covariate_obs,degree[degNum],coeff_true,var_coeff_true,var_coeff_scaling)

# solve SAA problems to estimate true objective value at this conditioning
_, SAAObj = solveSAAModel(demand_scen_MC)


end


#*========= STORE RESULTS ====================
<<<<<<< HEAD
if(true)
=======
if(storeResults)
>>>>>>> 1b8ef5ad9b3efd57ea13e3c9dd95c8b42a5d2191
	
	# write data to text file
	obj_est_file = subDirName2 * saaObjFile
	open(obj_est_file, "w") do f
		write(f,"$SAAObj")
	end	
	
	time_obj_file = subDirName2 * saaTimeFile
	open(time_obj_file, "w") do f
		write(f,"$SAATime")
	end	
	
end
#*============================================
