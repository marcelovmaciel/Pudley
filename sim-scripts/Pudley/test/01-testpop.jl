import Pkg

#Pkg.add("Revise")

import Revise

Pkg.activate("../../Pudley")

import Pudley, Pandas, Seaborn
const pdl = Pudley
const pd = Pandas
const sns = Seaborn
using Curry
import PyPlot
const plt = PyPlot

pop = pdl.createpop(pdl.Agent_o, 0.1, (-5, 5), 500)

plot_opinions(pop) = (sns.distplot ∘ pd.DataFrame ∘
                      partial(map,(pdl.getopinion ∘ pdl.getbelief)))(pop)



#const p = 0.9

# getpairbs(pairs) = map(partial(map, pdl.getbelief), pairs)

# rlbelief(pairs) = (first.(getpairbs(pairs)), last.(getpairbs(pairs)))

plot_opinions(pop)

sns.savefig("imgs/plot0.png")
plt.figure()

for i in range(1, stop = 2000)
    pdl.uppudleypop!(pop)
    fig = plot_opinions(pop)
    sns.savefig("imgs/plot$(i).png")
    plt.figure()

end

