import Pkg

#Pkg.add("Revise")

import Revise

Pkg.activate("../../Pudley")

import Pudley ,  Pandas, Seaborn
const pdl = Pudley
const pd = Pandas
const sns = Seaborn
import PyPlot
const plt = PyPlot
using ProgressMeter

using Curry
plt.ion()
using  Plots
Plots.gr(legend = false)


#@code_warntype pdl.createpop(pdl.Agent_o, 2., (-5, 5), 500)

#@time pdl.createpop(pdl.Agent_o, 2., (-5, 5), 500)
#pairs = Array{Tuple{eltype(pop)}, 1}(undef, length(pop))

plot_opinions(pop) = (sns.distplot ∘ pd.DataFrame ∘
                      partial(map,(pdl.getopinion ∘ pdl.getbelief)))(pop)

#@time pdl.getpairs(pop)
#const p = 0.9

# getpairbs(pairs) = map(partial(map, pdl.getbelief), pairs)

# rlbelief(pairs) = (first.(getpairbs(pairs)), last.(getpairbs(pairs)))

# ax = plot_opinions(pop)
# ax.set_title("iteration 0")

# sns.savefig("imgs/plot0.png")
# plt.figure()

function getstatearray(pop;  simend = 2000)
    result = Array{eltype(pop)}(undef, length(pop), simend)
    result[:, 1] .= deepcopy(pop)
    for i in range(2, stop = simend)
        pdl.uppudleypop!(pop)
        result[:, i] .= deepcopy(pop)
    end
    return(result)
end


function animateseries(simresult; interpolation = 5)
    fig1 = Plots.plot(show = false, xlabel = "iterations",
                ylabel = "opinions",
                    dpi = 80)
 anim =  Plots.@animate  for i in 1:size(simresult)[2]
        Plots.plot!(fig1,
              partial(map,(pdl.getopinion ∘ pdl.getbelief))(simresult[:,i]),
        linealpha = 0.2)
    end
    #   Plots.png("tseries")
    # Plots.gui(fig1)
    Plots.gif(anim, "anim_fps15.gif", fps = 15)
end


function plotseries(simresult;
             plotfn = (fig, x) ->  Plots.plot!(fig,
                                              partial(map,
                                                      (pdl.getopinion ∘ pdl.getbelief))(x),
                                              linealpha = 0.2))
    fig1 = Plots.plot(show = false, xlabel = "iterations",
                ylabel = "opinions",
                    dpi = 200)
    for i in 1:size(simresult)[1]
        plotfn(fig1, simresult[i, :])
    end
    #Plots.png("tseries")
    Plots.gui(fig1)
    return(fig1)
end

function plotseries(simresult, ylim)
    plotseries(simresult,
               plotfn = (fig, x) ->  Plots.plot!(fig,
                                                partial(map,
                                                        (pdl.getopinion ∘ pdl.getbelief))(x),
                                                ylim = ylim
                                                linealpha = 0.2))
end






pop = pdl.createpop(pdl.Agent_o, 2., (-5, 5), 500);

result = getstatearray(pop);

fig1 = plotseries(result)

fig2 = plotseries(result, (-20, 20))

fig3 = plotseries(result, (-5,5))

plot(fig1, fig2, fig3,  layout = (3,1))

Plots.png("test1")
