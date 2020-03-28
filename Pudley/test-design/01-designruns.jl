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

for iteration  in 1:20

    n = 2
    t = 15_000

    m = pdl.model_initialize(n = n)
    agent_properties = [:id, :r, :old_σ, :old_o]
    when = map(i -> floor(Int64, i), collect(range(0, step = 1000, stop = t)))
    data = pdl.Abm.step!(m, pdl.agent_step!, pdl.model_step!, t, agent_properties, when = when)

    global data

    p1 = plot(
        data[!, :step],
        data[!, :r],
        group = data[!, :id],
        alpha = 0.5,
        line = 4,
        title = "xr , $n agents, iteration $iteration",
        legend = false,
    )


    p2 = plot(
        data[!, :step],
        data[!, :old_σ],
        group = data[!, :id],
        alpha = 0.5,
        line = 4,
        legend = false,
        title = "sigma, $n agents, iteration $iteration",
    )

    p3 = plot(
        data[!, :step],
        data[!, :old_o],
        group = data[!, :id],
        alpha = 0.5,
        line = 4,
        legend = false,
        title = "o, $n agents, iteration $iteration",
    )


    plot(p1,p2,p3, layout = (3,1))
    savefig("plot-n(2)/plot-n($n)-iteration($iteration).png")
    p1 = nothing
    p2 = nothing
    p3 = nothing
end

last(data,20)

# using DataVoyager, VegaLite, ElectronDisplay
# v = Voyager(data)
