import Pkg

#Pkg.add("Revise")

import Revise

Pkg.activate("../../Pudley")

import Pudley, Pandas, Seaborn
const pdl = Pudley
const pd = Pandas
const sns = Seaborn
import PyPlot
const plt = PyPlot
using ProgressMeter


plt.ioff()

pop = pdl.createpop(pdl.Agent_o, 2., (-5, 5), 500)

plot_opinions(pop) = (sns.distplot∘ pd.DataFrame ∘
                      partial(map,(pdl.getopinion ∘ pdl.getbelief)))(pop)



#const p = 0.9

# getpairbs(pairs) = map(partial(map, pdl.getbelief), pairs)

# rlbelief(pairs) = (first.(getpairbs(pairs)), last.(getpairbs(pairs)))

ax = plot_opinions(pop)
ax.set_title("iteration 0")

sns.savefig("imgs/plot0.png")
plt.figure()


@showprogress for i in range(1, stop = 2000)
    pdl.uppudleypop!(pop)
    fig = plot_opinions(pop)
    fig.set_title("iteration $(i)")
    sns.savefig("imgs/plot$(i).png")
    plt.figure()

end

