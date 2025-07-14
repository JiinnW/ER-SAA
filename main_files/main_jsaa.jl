# Main file for solving the J-SAA and J+-SAA problems


using Distributions, StatsFuns, StatsBase, JuMP, Gurobi, GLMNet


const gurobi_env = Gurobi.Env()



# read these as inputs from the corresponding "instance file"
modRepNum = parse(Int, ARGS[1])
degNum = parse(Int, ARGS[2])
dataRepNum = parse(Int, ARGS[3])
sampSizeNum = parse(Int, ARGS[4])



#*========= MODEL INFORMATION ==========
const caseNum = 1
const paramsFile = "../parameter_settings/params_case" * string(caseNum) * "_jsaa.jl"
#*======================================



#*========= INCLUDE FILES ====================
include("../maxParameters.jl")
include("../randomSeeds.jl")

include(paramsFile)
# the next two data files are defined in paramsFile
include(modelFile)
include(dataFile)

include("../solution_methods/regressionMethods.jl")
include("../solution_methods/genJSAAScenarios.jl")
include("../solution_methods/solveModel.jl")
include("../solution_methods/estimateSolnCost.jl")
include("../solution_methods/evaluateSoln.jl")
#*======================================



# set seed for reproducibility
Random.seed!(startingSeed)



# directory name for storing results
const baseDirName = "../output/case" * string(caseNum) * "_jsaa/" * "mod_" * string(modRepNum) * "/" * "deg_" * string(degNum) * "/"
const subDirName = baseDirName * "rep_" * string(dataRepNum) * "/"
const subDirName2 = subDirName * regressionMethod * "/" * "samp_" * string(sampSizeNum) * "/"
mkpath(subDirName2)



#*========= PRINT OPTIONS ====================
const storeResults = false

const infoFile = "ddsp.txt"
const modelDataFile = "model_data.txt"
const numSampFile = "num_samples_" * regressionMethod * ".txt"

const jsaaObjFile = "jsaa_obj.txt"
const jsaaDDObjFile = "jsaa_ddobj.txt"
const jpsaaObjFile = "jpsaa_obj.txt"
const jpsaaDDObjFile = "jpsaa_ddobj.txt"
const jsaaTimeFile = "jsaa_time.txt"

const covRealFile = "covariate_obs.txt"
#*======================================
	


#*========= GENERATE MODEL PARAMETERS ====================
	
Random.seed!(randomSeeds_models[modRepNum])

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
		write(f,"sample sizes: $numDataSamples \n")
		write(f,"heteroscedasticity level: $het_level \n")
		write(f,"demand_errors_scaling: $demand_errors_scaling \n")
		write(f,"regressionMethod: $regressionMethod \n\n")
		
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
	
	samp_size_file = baseDirName * numSampFile
	open(samp_size_file, "w") do f
		for i = 1:length(numDataSamples)
			write(f,"$(numDataSamples[i]) \n")
		end
	end
	
end
#*============================================



#*========= GENERATE DATA REPLICATE ====================

Random.seed!(randomSeeds_data[dataRepNum])

covariate_obs = generateCovariateReal(numCovariates,covariate_mean,covariate_covMat)

demand_data, covariate_data = generateDemandData(numCovariates,numDataSamples[sampSizeNum],degree[degNum],covariate_mean,covariate_covMat,coeff_true,var_coeff_true,var_coeff_scaling)


#*========= STORE RESULTS ====================
if(storeResults)
	
	cov_real_file = subDirName * covRealFile
	open(cov_real_file, "w") do f
		write(f,"covariate_obs = $covariate_obs")
	end	
	
end
#*============================================



#*========= SOLVE THE J-SAA and J+-SAA MODELS ====================

jsaaTime = @elapsed begin


demand_scen_jsaa, demand_scen_jpsaa = generateJSAAScenarios(demand_data,covariate_data,covariate_obs,regressionMethod)

z_soln_jsaa, objDDJSAA = solveSAAModel(demand_scen_jsaa)

jsaaObjEstimates = estimateSolnQuality(z_soln_jsaa,covariate_obs,degree[degNum],numMCScenarios,numMCReplicates,coeff_true,var_coeff_true,var_coeff_scaling)


z_soln_jpsaa, objDDJpSAA = solveSAAModel(demand_scen_jpsaa)

jpsaaObjEstimates = estimateSolnQuality(z_soln_jpsaa,covariate_obs,degree[degNum],numMCScenarios,numMCReplicates,coeff_true,var_coeff_true,var_coeff_scaling)


end


#*========= STORE RESULTS ====================
if(true)
	
	# write data to text file
	obj_est_file1 = subDirName2 * jsaaObjFile
	open(obj_est_file1, "w") do f
		for i = 1:length(jsaaObjEstimates)
			write(f,"$(jsaaObjEstimates[i]) \n")
		end
	end	
	
	obj_est_file2 = subDirName2 * jpsaaObjFile
	open(obj_est_file2, "w") do f
		for i = 1:length(jpsaaObjEstimates)
			write(f,"$(jpsaaObjEstimates[i]) \n")
		end
	end	
	
	ddobj_est_file1 = subDirName2 * jsaaDDObjFile
	open(ddobj_est_file1, "w") do f
		write(f,"$objDDJSAA")
	end	
	
	ddobj_est_file2 = subDirName2 * jpsaaDDObjFile
	open(ddobj_est_file2, "w") do f
		write(f,"$objDDJpSAA")
	end	
	
	time_obj_file = subDirName2 * jsaaTimeFile
	open(time_obj_file, "w") do f
		write(f,"$jsaaTime")
	end	
	
end
#*============================================
