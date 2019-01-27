using Pkg
Pkg.activate("../sim-scripts/Poodl")

using Revise
using JLD2
import Poodl
const  pdl  = Poodl

pdl.mkdirs("data")

problem = Dict("num_vars" => 6,
            "names" => [ "size_nw",
                         "n_issues", "p", "σ", "ρ", "p_intran"],
            "bounds" => [[500, 5000],
                         [1, 10],
                         [0.1, 0.99],
                         [0.01, 0.5],
                         [0.0, 0.1],
                         [0.0, 0.3]])

paramvalues5k_6params = pdl.boundsdict_toparamsdf(problem) 


poodlvect★ = pdl.poodlparamsvec(paramvalues5k_6params,
                               time = 1_000_000,
                               p★calculator = pdl.calculatep★);

initcondmeasure = pdl.initcondstds(poodlvect★)

poodlvect★ = nothing

Ysaltelli6params = pdl.sweep_sample(paramvalues5k_6params,
                                    time = 1_000_000,
                                    p★calculator = pdl.calculatep★);

ParamSweep6params★ = pdl.ParamSweep_inout("Six parameters and sample of 5k, p★",
                                     problem, paramvalues5k_6params,
                                     Ysaltelli6params, initcondmeasure)

@save "data/ParamSweep6params-star1.jld2" ParamSweep6params★

println("done")


