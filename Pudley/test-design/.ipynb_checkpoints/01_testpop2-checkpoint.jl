import Pkg


Pkg.activate("../../Pudley")
Pkg.instantiate()
Pkg.precompile()

import Revise
import Pudley
const pdl = Pudley
using BenchmarkTools
using DataVoyager, VegaLite, ElectronDisplay
import Base.Filesystem
const filesystem = Base.Filesystem

m = pdl.model_initialize()

n = 100_000

agent_properties = [:o, :σ]

when = map(i -> floor(Int, i), collect(range(0, step = 1000, stop = n)))

when[1] = 1

data = pdl.Abm.step!(
    m,
    pdl.Abm.dummystep,
    pdl.pudley_step!,
    20_000,
    agent_properties,
    when = when,
)     # run the model one step

v = Voyager(data)

plts = ("img" |> filesystem.readdir .|> x -> filesystem.joinpath("./img", x))

function pltfile(plt)
    if occursin(".vegalite", plt)
        data |> load(plt) |> save("$(split(plt, "vegalite")[1])png")
    end
end

pltfile.(plts)

# data |> @vlplot(
#     mark={
#         :line,
#         point=true
#     },
#     x=:step,
#     y=:o,
#     color="id:n", legend =
# )


# ax = lineplot(x="step", y="o", hue="id",
#                    data=data)


# fig = @df data plot(:step, :o, group = :id, dpi = 200)

# if  "img" in filesystem.readdir(".")
#     mkdir("./img")
# end


# Plots.png("tseries", dpi = 200)
