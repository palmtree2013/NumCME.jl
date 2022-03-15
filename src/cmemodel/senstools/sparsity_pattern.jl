export propensitygrad_sparsity_pattern

function propensitygrad_sparsity_pattern(speciescount, parametercount, propensities, parameters)    
    propensitycount = length(propensities)
    @variables t, x[1:speciescount](t), alphas[1:propensitycount](t)
    @parameters p[1:parametercount]
    eqs = Vector{Equation}([])
    for r in 1:propensitycount 
        if istimevarying(propensities[r])
            push!(eqs, alphas[r]~propensities[r](t, x, p))        
        else 
            push!(eqs, alphas[r]~propensities[r](x, p))        
        end
    end
    @named sys = ODESystem(eqs,t,[x;alphas],p)
    eqdep = equation_dependencies(sys; variables=[p...])
    depgraph = asgraph(eqdep, Dict([s=>i for (i,s) in enumerate(p)]))

    I = Vector{UInt32}()
    J = Vector{UInt32}()
    vals = Vector{Bool}() 
    for r in 1:propensitycount 
        for ip in depgraph.fadjlist[r]
            push!(I, r)
            push!(J, ip)
            push!(vals, true)
        end
    end

    return sparse(I,J,vals)
end