import Pkg

using ClearStacktrace
using JuliaFormatter
format(".")


Pkg.activate("../../Pudley")

Pkg.instantiate()
Pkg.precompile()

import Revise
import Pudley
const pdl = Pudley
using BenchmarkTools
using Test

n = 2
interval = (-20,20)


@inferred pdl.Agent_o()
@inferred pdl.space(n)
#@code_warntype pdl.model(n)
@inferred pdl.model(n)

@code_warntype pdl.emptypop(pdl.Agent_o, n)
@inferred pdl.emptypop(pdl.Agent_o, n)
@time pdl.emptypop(pdl.Agent_o, n)

@code_warntype pdl.opinionarray(interval, n)
@time pdl.opinionarray(interval, n)
@inferred pdl.opinionarray(interval, n)

pop = pdl.emptypop(pdl.Agent_o, n)
oarray =pdl.opinionarray(interval, n)
σ = big(1.)

@code_warntype  pdl.fillpop!(pop, oarray, σ)
@time pdl.fillpop!(pop, oarray, σ)
@inferred pdl.fillpop!(pop, oarray, σ)

@code_warntype pdl.createpop(pdl.Agent_o, n, σ, interval)
@time pdl.createpop(pdl.Agent_o, n, σ, interval)
@inferred pdl.createpop(pdl.Agent_o, n, σ, interval)

filledpop = pdl.createpop(pdl.Agent_o, n, σ, interval)
@testset "Test central agent attributes" begin

    @test filledpop[1].id == 1
    @test filledpop[1].old_o == big(0.)
end

m = pdl.model(2)

@code_warntype pdl.fillmodel!(m, filledpop)
@time pdl.fillmodel!(m, filledpop)
@inferred pdl.fillmodel!(m, filledpop)

@code_warntype pdl.getjtointeract(1, m)
@time pdl.getjtointeract(1, m)
@inferred pdl.getjtointeract(1, m) #type instability

@code_warntype pdl.getjstointeract(m)
@time pdl.getjstointeract(m)
@inferred pdl.getjstointeract(m) #type instability

@code_warntype pdl.Abm.id2agent(1,m)
@inferred filledpop[1] # type instability !!!!!!!
@inferred pdl.Abm.id2agent(1,m) #type instability
@inferred  pdl.o(filledpop[1])
@inferred pdl.o(pdl.Abm.id2agent(1,m))

apair = map(i -> pdl.Abm.id2agent(i,m),
            (1,2))

@code_warntype pdl.changingterm★(apair...)
@time pdl.changingterm★(apair...)
@inferred pdl.changingterm★(apair...)

p = 0.9

@code_warntype pdl.calculatep★(p, apair...)
@time pdl.calculatep★(p, apair...)
@inferred pdl.calculatep★(p, apair...)

p★ = pdl.calculatep★(p, apair...)

@code_warntype pdl.calc_posterior_o(p★, apair...)
@time pdl.calc_posterior_o(p★, apair...)
@inferred pdl.calc_posterior_o(p★, apair...)

@code_warntype pdl.calcσ★(p★, apair...)
@time pdl.calcσ★(p★, apair...)
@inferred pdl.calcσ★(p★, apair...)


@code_warntype pdl.model_initialize(n = n )
@time pdl.model_initialize(n = n )
@inferred pdl.model_initialize(n = n )

@test pdl.xr(apair[1], m) == 0
@test pdl.xr(apair[2], m) != 0
