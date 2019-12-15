import Pkg


Pkg.activate("../../Pudley")
Pkg.instantiate()
Pkg.precompile()

import Revise
import Pudley 
const pdl = Pudley
using BenchmarkTools
using DataVoyager


m = pdl.model_initialize()

n = 20_000

agent_properties = [:o , :σ]

when = map(i -> floor(Int, i),
           collect(range(0,step= 1000,stop = n)))

when[1] = 1

data = pdl.Abm.step!(m,
              pdl.Abm.dummystep,
              pdl.pudley_step!,
              20_000, agent_properties, when = when)     # run the model one step

v = Voyager(data)
