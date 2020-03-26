import Pkg

using ClearStacktrace
using JuliaFormatter
format(".")
format("../../Pudley/src")


Pkg.activate("../../Pudley")

Pkg.instantiate()
Pkg.precompile()

import Revise
import Pudley
const pdl = Pudley

import Base.Filesystem
const filesystem =  Base.Filesystem
using Plots

for n  = [2,5,10, 20]
    t = 15_000

    m = pdl.model_initialize(n = n)
    agent_properties = [:id, :r, :old_σ]

    when = map(i -> floor(Int64, i), collect(range(0, step = 1000, stop = t)))

    data = pdl.Abm.step!(m, pdl.agent_step!, pdl.model_step!, t, agent_properties, when = when)     # run the model one step
global data
    p1 = plot(
        data[!, :step],
        data[!, :r],
        group = data[!, :id],
        alpha = 0.5,
        line = 4,
        title = "xr , ($n) agents",
        legend = false,
    )


    p2 = plot(
        data[!, :step],
        data[!, :old_σ],
        group = data[!, :id],
        alpha = 0.5,
        line = 4,
        legend = false,
        title = "sigma, ($n) agents",
    )

    plot(p1,p2, layout = (1,2))
    savefig("plot-n($n).png")
    p1 = nothing
    p2 = nothing
end


last(data,20)

using DataVoyager, VegaLite, ElectronDisplay
v = Voyager(data)
