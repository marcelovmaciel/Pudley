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
const filesystem = Base.Filesystem
using Plots


for n in [5, 10, 20]
    t = 500
    interval = (1, 5)
    m = pdl.model_initialize(n = n, interval = interval)
    agent_properties = [:id, :r, :old_σ, :old_o]
    when = map(i -> floor(Int64, i), collect(range(0, step = 1, stop = t)))
    data =
        pdl.Abm.step!(m, pdl.agent_step!, pdl.model_step!, t, agent_properties, when = when)

    global data

    p1 = plot(
        data[!, :step],
        data[!, :r],
        group = data[!, :id],
        alpha = 0.5,
        line = 4,
        title = "xr , $n agents",
        legend = false,
    )


    p2 = plot(
        data[!, :step],
        data[!, :old_σ],
        group = data[!, :id],
        alpha = 0.5,
        line = 4,
        legend = false,
        title = "sigma, $n agents",
    )

    p3 = plot(
        data[!, :step],
        data[!, :old_o],
        group = data[!, :id],
        alpha = 0.5,
        line = 4,
        legend = false,
        title = "o, $n agents",
    )


    plot(p1, p2, p3, layout = (3, 1))
    savefig("plot-n(2)/plot-n($n).png")
    p1 = nothing
    p2 = nothing
    p3 = nothing
end



# run replicates
# gotta dry this

using DataFrames: Not, select!
using Statistics: mean,median




for n in [5, 10, 20]
    t = 500
    interval = (1, 5)
    m = pdl.model_initialize(n = n, interval = interval)
    agent_properties = [:id, :r, :old_σ, :old_o]
    when = map(i -> floor(Int64, i), collect(range(0, step = 1, stop = t)))
    data =
        pdl.Abm.parallel_replicates(m, pdl.agent_step!, pdl.model_step!, t, agent_properties, when= when,replicates = 100, step0 = true)



    data = pdl.Abm.aggregate(data, [:step, :id],  median);
    global data
    select!(data, Not(:replicate_median))


    p1 = plot(
        data[!, :step],
        data[!, :r_median],
        group = data[!, :id],
        alpha = 0.5,
        line = 4,
        title = "xr , $n agents  median of a 100 replicates",
        legend = false,
    )


    p2 = plot(
        data[!, :step],
        data[!, :old_σ_median],
        group = data[!, :id],
        alpha = 0.5,
        line = 4,
        legend = false,
        title = "sigma, $n agents,  median of a 100 replicates",
    )

    p3 = plot(
        data[!, :step],
        data[!, :old_o_median],
        group = data[!, :id],
        alpha = 0.5,
        line = 4,
        legend = false,
        title = "o, $n agents, median of a 100 replicates",
    )


    plot(p1, p2, p3, layout = (3, 1))
    savefig("plot-n(2)/median-replicate-plot-n($n).png")
    p1 = nothing
    p2 = nothing
    p3 = nothing

end




for n in [5, 10, 20]
    t = 500
    interval = (1, 5)
    m = pdl.model_initialize(n = n, interval = interval)
    agent_properties = [:id, :r, :old_σ, :old_o]
    when = map(i -> floor(Int64, i), collect(range(0, step = 1, stop = t)))
    data =
        pdl.Abm.parallel_replicates(m, pdl.agent_step!, pdl.model_step!, t, agent_properties, when= when,replicates = 100, step0 = true)



    data = pdl.Abm.aggregate(data, [:step, :id],  mean);
    global data
    select!(data, Not(:replicate_mean))


    p1 = plot(
        data[!, :step],
        data[!, :r_mean],
        group = data[!, :id],
        alpha = 0.5,
        line = 4,
        title = "xr , $n agents, mean of a  100 replicates",
        legend = false,
    )


    p2 = plot(
        data[!, :step],
        data[!, :old_σ_mean],
        group = data[!, :id],
        alpha = 0.5,
        line = 4,
        legend = false,
        title = "sigma, $n agents,  mean of a  100 replicates",
    )

    p3 = plot(
        data[!, :step],
        data[!, :old_o_mean],
        group = data[!, :id],
        alpha = 0.5,
        line = 4,
        legend = false,
        title = "o, $n agents,  mean of a  100 replicates",
    )


    plot(p1, p2, p3, layout = (3, 1))
    savefig("plot-n(2)/mean-replicate-plot-n($n).png")
    p1 = nothing
    p2 = nothing
    p3 = nothing

end

last(data, 20)
first(data, 20)
data

when
# using DataVoyager, VegaLite, ElectronDisplay
# v = Voyager(data)
