# Estimate cost of first-stage resource allocation decision given scenarios of the demands

# given decisions and scenarios of the demands, estimate the objective cost
function estimateCostOfSoln(z_soln::Array{Float64},demand_scen::Array{Float64,2})
	
	mod = Model(() -> Gurobi.Optimizer(gurobi_env))
	set_optimizer_attribute(mod, "OutputFlag", 0)
	set_optimizer_attribute(mod, "Threads", maxNumThreads)

	@variable(mod, v[1:numResources,1:numCustomers] >= 0)
	@variable(mod, w[1:numCustomers] >= 0)

	
	@objective(mod, Min, sum(recourseCostCoeff[j]*w[j] for j=1:numCustomers))
							
	@constraint(mod, [i=1:numResources], sum(v[i,j] for j = 1:numCustomers) <= rho[i]*z_soln[i])
	@constraint(mod, con1[j=1:numCustomers], sum(mu[i,j]*v[i,j] for i = 1:numResources) + w[j] >= 0)
	

	numScenarios::Int64 = size(demand_scen,1)
	solnCost::Float64 = 0.0
	
	for s = 1:numScenarios		
		for j = 1:numCustomers
			set_normalized_rhs(con1[j], demand_scen[s,j])
		end

		status = optimize!(mod)
		solnCost += objective_value(mod)
	end
	
	solnCost /= numScenarios
	solnCost += sum(costVector[i]*z_soln[i] for i=1:numResources)
	
	return solnCost
end