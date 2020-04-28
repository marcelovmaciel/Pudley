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

using DataFrames: Not, select!
using Statistics: mean, median


const zoomplotdenominators = [10, 100, 10000]

getys(p) = reduce(vcat, (el -> el.plotattributes[:y]).(p.series_list))

function getplotminmax(p)
    ys = getys(p)
    min(ys...), max(ys...)
end

getplotmedian(p) = median(getys(p))

medianplotbounds(n, p) = (-(n * getplotmedian(p)), n * getplotmedian(p))

zoomplotbounds(n, p) = map(x -> x / n, getplotminmax(p))


for i = 1:10
    n =20
        t = 500
        interval = (1, 5)
        m = pdl.model_initialize(n = n, interval = interval)
        agent_properties = [:id, :r, :old_σ, :old_o]
        when = map(i -> floor(Int64, i), collect(range(0, step = 1, stop = t)))
        data = pdl.Abm.step!(
            m,
            pdl.agent_step!,
            pdl.model_step!,
            t,
            agent_properties,
            when = when,
        )

        p1 = plot(
            data[!, :step],
            data[!, :r],
            group = data[!, :id],
            alpha = 0.5,
            line = 4,
            title = "xr, $n agents, run $(i)",
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

        p31 = plot(
            data[!, :step],
            data[!, :r],
            group = data[!, :id],
            alpha = 0.5,
            line = 4,
            ylims = zoomplotbounds(
                zoomplotdenominators[1],
                p1 ),
            title = "xr, $n agents, range/$(zoomplotdenominators[1])",
            legend = false,
        )

        p32 = plot(
            data[!, :step],
            data[!, :r],
            group = data[!, :id],
            alpha = 0.5,
            line = 4,
            ylims = zoomplotbounds(
                zoomplotdenominators[2],
                p1,
            ),
            title = "xr, $n agents, range/$(zoomplotdenominators[2])",
            legend = false,
        )

        p33 = plot(
            data[!, :step],
            data[!, :r],
            group = data[!, :id],
            alpha = 0.5,
            line = 4,
            ylims = zoomplotbounds(
                zoomplotdenominators[3],
                p1,
            ),
            title = "xr, $n agents, range/$(zoomplotdenominators[3])",
            legend = false,
        )


        p311 = plot(
            data[!, :step],
            data[!, :r],
            group = data[!, :id],
            alpha = 0.5,
            line = 4,
            ylims = medianplotbounds(zoomplotdenominators[1], p1),
            title = "xr, $n agents, range = +-$(zoomplotdenominators[1])*median",
            legend = false,
        )

        p312 = plot(
            data[!, :step],
            data[!, :r],
            group = data[!, :id],
            alpha = 0.5,
            line = 4,
            ylims = medianplotbounds(zoomplotdenominators[2], p1),
            title = "xr , $n agents, range =  +-$(zoomplotdenominators[2])*median",
            legend = false,
        )

        p313 = plot(
            data[!, :step],
            data[!, :r],
            group = data[!, :id],
            alpha = 0.5,
            line = 4,
            ylims = medianplotbounds(zoomplotdenominators[3], p1),
            title = "xr, $n agents, range =  +-$(zoomplotdenominators[3])*median",
            legend = false,
        )


    plot(p1, p31, p311, p2, p32, p312, p3, p33, p313,
         layout = (3, 3), dpi =200,
         titlefont=Plots.font("sans-serif", pointsize=round(5.0)))

        savefig("plot-n(2)/plot-n($n)-run($i).png")
        p1 = nothing
        p2 = nothing
        p3 = nothing
        p31, p32, p33 = nothing, nothing, nothing
        p311, p312, p313 = nothing, nothing, nothing
    end














#try animation here


t = 500
n = 20
interval = (1, 5)
m = pdl.model_initialize(n = n, interval = interval)
agent_properties = [:id, :r, :old_σ, :old_o]
when = map(i -> floor(Int64, i), collect(range(0, step = 1, stop = t)))
data = pdl.Abm.step!(m, pdl.agent_step!, pdl.model_step!, t, agent_properties, when = when)

p = plot(
    data[!, :step],
    data[!, :r],
    group = data[!, :id],
    alpha = 0.5,
    line = 4,
    title = "xr , $n agents, run $(i)",
    legend = false,
)


anim = Animation()
for i = 1:t
    push!(plot(i, [data[i, :r]]), i, [data[i, :r]])
    frame(anim)

end







last(data, 20)
first(data, 20)
data

when


# run replicates
# gotta dry this



for n in [5, 10, 20]
    t = 500
    interval = (1, 5)
    m = pdl.model_initialize(n = n, interval = interval)
    agent_properties = [:id, :r, :old_σ, :old_o]
    when = map(i -> floor(Int64, i), collect(range(0, step = 1, stop = t)))
    data = pdl.Abm.parallel_replicates(
        m,
        pdl.agent_step!,
        pdl.model_step!,
        t,
        agent_properties,
        when = when,
        replicates = 100,
        step0 = true,
    )


    data = pdl.Abm.aggregate(data, [:step, :id], median)
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
    data = pdl.Abm.parallel_replicates(
        m,
        pdl.agent_step!,
        pdl.model_step!,
        t,
        agent_properties,
        when = when,
        replicates = 100,
        step0 = true,
    )



    data = pdl.Abm.aggregate(data, [:step, :id], mean)
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


fieldnames(typeof(zoomplotbounds(4)))

last(data, 20)
first(data, 20)
data

when
# using DataVoyager, VegaLite, ElectronDisplay
# v = Voyager(data)
