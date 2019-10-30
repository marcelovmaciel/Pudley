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

pop = pdl.createpop(pdl.Agent_o, 0.1, (0.0, 1.0), 500)

plot_opinions(pop) = (sns.distplot ∘ pd.DataFrame ∘
                      partial(map,(pdl.getopinion ∘ pdl.getbelief)))(pop)


#pairs = pdl.getpairs(pop)

#const p = 0.9

# getpairbs(pairs) = map(partial(map, pdl.getbelief), pairs)

# rlbelief(pairs) = (first.(getpairbs(pairs)), last.(getpairbs(pairs)))

plot_opinions(pop)

sns.savefig("imgs/plot1.png")
plt.figure()
plt.close()
for i in range(1, stop = 200)
    pdl.update_o!.(pop,
                   pdl.calc_posterior_os(pdl.getpairs(pop)))
    fig = plot_opinions(pop)
    sns.savefig("imgs/plot$(i).png")
    plt.figure()
    plt.close()
end

