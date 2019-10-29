import Pkg

#Pkg.add("Revise")

import Revise

Pkg.activate("../../Pudley")
Pkg.instantiate()
# foreach(Pkg.add, ("PyCall","PyPlot", "Pandas",
#                   "DataFrames", "Seaborn", "LightGraphs", "MetaGraphs", "Distributions",
#                   "Parameters", "ProgressMeter", "JLD2", "Random", "Statistics", "StatsBase"))

import Pudley, Pandas, Seaborn
const pdl = Pudley
const pd = Pandas
const sns = Seaborn
using Curry
pop = pdl.createpop(pdl.Agent_o, 0.1, (0.0, 1.0), 500)



# opinions = (pdl.getpropertylist(pop, :b) |>
#             foo -> pdl.getpropertylist(foo, :o) |>
#             pd.DataFrame |> sns.distplot)


opinions = (sns.distplot ∘ pd.DataFrame ∘ partial(map,(pdl.getopinion ∘ pdl.getbelief)))(pop)




       


