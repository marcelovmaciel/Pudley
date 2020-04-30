import Pkg
using ClearStacktrace
using JuliaFormatter

format(".")
format("../../Pudley/src")

Pkg.activate("../../Pudley")

Pkg.instantiate()
Pkg.resolve()
Pkg.precompile()

import Revise
import Pudley
const pdl = Pudley


n = 100
t = 500
interval = (-10, 10)
agent_properties = [:r, :old_σ, :old_o]


for repetition = 1:10
    m = pdl.model_initialize(n = n, interval = interval)
    data = pdl.Abm.run!(m, pdl.agent_step!, pdl.model_step!, t, adata = agent_properties)[1]
    pdl.threecol_iterplot(data, repetition)
end
