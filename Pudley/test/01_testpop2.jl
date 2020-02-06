import Pkg

Pkg.activate("Pudley")
Pkg.instantiate()
Pkg.precompile()

import Revise
import Pudley
const pdl = Pudley
using BenchmarkTools
# using DataVoyager,
#     VegaLite, ElectronDisplay
import Base.Filesystem
const filesystem = Base.Filesystem
using Plots

n = 20
m = pdl.model_initialize(n=n)

t = 1000

agent_properties = [:o , :σ]

when = map(i -> floor(Int, i),
           collect(range(0,step= 10,stop = t)))

when[1] = 1

data = pdl.Abm.step!(m,
              pdl.Abm.dummystep,
              pdl.pudley_step!,
              t, agent_properties, when = when)     # run the model one step

# v = Voyager(data)

p1 = plot(
    data[!, :step],
    data[!, :o],
    group = data[!, :id],
    alpha = 0.5,
    line=4,
    marker=([:hex :d]),
    title= "opinion"
    )



 p2 = plot(
        data[!, :step],
        data[!, :σ],
        group = data[!, :id],
        alpha = 0.5,
        line=4,
        marker=([:hex :d]),
        title= "sigma"
         )
    
plot(p1,p2, layout = (1,2))
savefig("plot-n($n).png")
print(data)


# plts = ("img" |>
#         filesystem.readdir .|>
#         x -> filesystem.joinpath("./img", x))

# function pltfile(plt)
#     if occursin(".vegalite", plt)
#         data |> load(plt) |> save("$(split(plt, "vegalite")[1])png")
#     end
# end

# pltfile.(plts)

# data |> @vlplot(
#     mark={
#         :line,
#         point=true
#     },
#     x=:step,
#     y=:o,
#     color="id:n"
# )

# ax = lineplot(x="step", y="o", hue="id",
#                    data=data)


# fig = @df data plot(:step, :o, group = :id, dpi = 200)

# if  "img" in filesystem.readdir(".")
#     mkdir("./img")
# end


# Plots.png("tseries", dpi = 200)
